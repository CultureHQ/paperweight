# frozen_string_literal: true

class StorageTest < ActiveSupport::TestCase
  def test_put
    Aws.config[:s3] = { stub_responses: { put_object: {} } }

    client = Paperweight::Storage::Remote.new

    with_file('small.png') do |file|
      client.put(file, '0000-aaaa-1111-bbbb')
    end
  end

  def test_delete
    Aws.config[:s3] = { stub_responses: { delete_object: {} } }

    client = Paperweight::Storage::Remote.new
    client.delete('0000-aaaa-1111-bbbb')
  end

  def test_adapter_production
    with_adapter 'production' do |adapter|
      assert_kind_of Paperweight::Storage::Remote, adapter
    end
  end

  def test_adapter_development
    with_adapter 'development' do |adapter|
      assert_kind_of Paperweight::Storage::Local, adapter
    end
  end

  def test_adapter_test
    with_adapter 'test' do |adapter|
      assert_kind_of Paperweight::Storage::Local, adapter
    end
  end

  private

  def with_adapter(env)
    Paperweight::Storage.instance_variable_set(:@adapter, nil)
    Rails.stub(:env, env) { yield Paperweight::Storage.adapter }
  ensure
    Paperweight::Storage.instance_variable_set(:@adapter, nil)
  end

  def with_file(filename, &block)
    File.open(File.join('test', 'files', filename), &block)
  end
end
