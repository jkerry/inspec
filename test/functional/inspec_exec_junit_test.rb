# encoding: utf-8
# author: John Kerry

require 'functional/helper'
require 'nokogiri'

describe 'inspec exec with junit formatter' do
  include FunctionalHelper

  it 'can execute a simple file with the junit formatter' do
    out = inspec('exec ' + example_control + ' --format junit --no-create-lockfile')
    out.stderr.must_equal ''
    out.exit_status.must_equal 0
    doc = Nokogiri::XML(out.stdout)
    doc.errors.length.must_equal 0
  end

  it 'can execute the profile with the junit formatter' do
    out = inspec('exec ' + example_profile + ' --format junit --no-create-lockfile')
    out.stderr.must_equal ''
    out.exit_status.must_equal 0
    doc = Nokogiri::XML(out.stdout)
    doc.errors.length.must_equal 0
  end

  describe 'execute a profile with junit formatting' do
    let(:doc) { Nokogiri::XML(inspec('exec ' + example_profile + ' --format junit --no-create-lockfile').stdout) }

    describe 'the document' do
      it 'has only one testsuite' do
        doc.xpath("//testsuite").length.must_equal 1
      end
    end
    describe 'the test suite' do
      let(:suite) { doc.xpath("//testsuites/testsuite").first}

      it 'must have 5 testcase children' do
        suite.xpath("//testcase").length.must_equal 5
      end

      it 'has the tests attribute with 5 total tests' do
        suite["tests"].must_equal "5"
      end

      it 'has the failures attribute with 0 total tests' do
        suite["failed"].must_equal "0"
      end

      it 'has 2 elements named "File /tmp should be directory"' do
        suite.xpath("//testcase[@name='File /tmp should be directory']").length.must_equal 2
      end

      describe 'the testcase named "gordon_config Can\'t find file ..."' do
        let(:gordon_yml_tests) { suite.xpath("//testcase[@class='gordon-1.0' and @name='gordon_config']") }
        let(:first_gordon_test) {gordon_yml_tests.first}

        it 'should be unique' do
          gordon_yml_tests.length.must_equal 1
        end

        it 'should be skipped' do
          first_gordon_test.xpath("//skipped").length.must_equal 1
        end
      end
    end
  end
end
