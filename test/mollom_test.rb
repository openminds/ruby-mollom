require 'test/unit'
require 'rubygems'
require 'mocha'

require 'mollom'

class Mollom
  # Unprivate all methods
  public :authentication_hash
  public :server_list
  public :send_command
end

class TestMollom < Test::Unit::TestCase
  def setup
    @mollom = Mollom.new(:private_key => 'xxxxxxxxx', :public_key => 'yyyyyyyyy')
  end
  
  def test_initialize
    assert_equal 'xxxxxxxxx', @mollom.private_key
    assert_equal 'yyyyyyyyy', @mollom.public_key
  end
  
  def test_authentication_hash
    time = mock
    time.expects(:strftime).with('%Y-%m-%dT%H:%M:%S.000+0000').returns('2008-04-01T13:54:26.000+0000')
    Time.expects(:now).returns(stub(:gmtime => time))
    Kernel.expects(:rand).with(2**31).returns(42)
    hash = @mollom.authentication_hash
    assert_equal("oWN15TqrbLVdTAgcuDmofskaNyM=", hash[:hash])
    assert_equal('yyyyyyyyy', hash[:public_key])
    assert_equal('2008-04-01T13:54:26.000+0000', hash[:time])
    assert_equal(42, hash[:nonce])
  end
  
  def test_server_list
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc3.mollom.com', :proto => 'http').returns([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}])
    assert_equal [{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}], @mollom.server_list
  end

  def test_server_list_with_first_server_bad
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc3.mollom.com', :proto => 'http').returns(nil)
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc2.mollom.com', :proto => 'http').returns([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}])
    assert_equal [{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}], @mollom.server_list
  end

  def test_server_list_with_all_servers_bad
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc3.mollom.com', :proto => 'http').returns(nil)
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc2.mollom.com', :proto => 'http').returns(nil)
    Mollom.any_instance.expects(:get_server_list_from).with(:host => 'xmlrpc1.mollom.com', :proto => 'http').returns(nil)
    assert_raise(Mollom::Error) { @mollom.server_list }
  end
  
  def test_get_server_list_from_with_ok_return
    xml_rpc = mock
    xml_rpc.expects(:call).times(1).with('mollom.getServerList', is_a(Hash)).returns(['http://172.16.0.1', 'http://172.16.0.2', 'https://172.16.0.2'])
    XMLRPC::Client.stubs(:new).with('xmlrpc.mollom.com', '/1.0').returns(xml_rpc)
    assert_equal([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}], @mollom.send(:get_server_list_from, {:host => 'xmlrpc.mollom.com', :proto => 'http'}))
  end
  
  def test_get_server_list_from_with_raising_return
    xml_rpc = mock
    xml_rpc.expects(:call).times(1).with('mollom.getServerList', is_a(Hash)).raises(XMLRPC::FaultException.new(1000, "Broken mollom"))
    XMLRPC::Client.stubs(:new).with('xmlrpc.mollom.com', '/1.0').returns(xml_rpc)
    assert_equal(nil, @mollom.send(:get_server_list_from, {:host => 'xmlrpc.mollom.com', :proto => 'http'}))
  end

  def test_get_server_list_from_with_timemout
    xml_rpc = mock
    xml_rpc.expects(:call).times(1).with('mollom.getServerList', is_a(Hash)).raises(Timeout::Error)
    XMLRPC::Client.stubs(:new).with('xmlrpc.mollom.com', '/1.0').returns(xml_rpc)
    assert_equal(nil, @mollom.send(:get_server_list_from, {:host => 'xmlrpc.mollom.com', :proto => 'http'}))
  end

  def test_server_list_force_reload
    Mollom.any_instance.expects(:get_server_list_from).times(2).with(:host => 'xmlrpc3.mollom.com', :proto => 'http').returns([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'https'}])
    
    @mollom.server_list
    @mollom.server_list
    @mollom.server_list
    @mollom.server_list(true)
  end
  
  def test_server_list_setter_with_good_list
    @mollom.server_list = [{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}]
    assert_equal [{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}], @mollom.instance_variable_get('@server_list')
  end
  
  def test_send_command_with_old_server_list
    @mollom.server_list = [{:ip => '172.16.0.1', :proto => 'http'}, {:ip => '172.16.0.2', :proto => 'http'}]
    assert_equal nil, @mollom.instance_variable_get('@server_list')
  end

  def test_send_command_with_bad_server_list
    @mollom.server_list = "404 Not Found Bad User Input"
    assert_equal nil, @mollom.instance_variable_get('@server_list')
  end

  
  def test_send_command_with_good_server
    Mollom.any_instance.expects(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo'))
    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    
    @mollom.send_command('mollom.testMessage', {:options => 'foo'})
  end
  
  
  def test_send_command_with_bad_http_response
    Mollom.any_instance.expects(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo')).raises(RuntimeError.new('HTTP-Error: 302 Found'))
    xml_rpc2 = mock
    xml_rpc2.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo'))
    
    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    XMLRPC::Client.expects(:new).with('172.16.0.2', '/1.0').returns(xml_rpc2)
    @mollom.send_command('mollom.testMessage', {:options => 'foo'})
  end
  
  def test_send_command_with_bad_server
    Mollom.any_instance.expects(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}, {:host => '172.16.0.2', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo')).raises(XMLRPC::FaultException.new(1200, "Redirect"))
    xml_rpc2 = mock
    xml_rpc2.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo'))
    
    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    XMLRPC::Client.expects(:new).with('172.16.0.2', '/1.0').returns(xml_rpc2)
    @mollom.send_command('mollom.testMessage', {:options => 'foo'})
  end
  
  def test_send_command_with_reload_exception
    Mollom.any_instance.stubs(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}], [{:host => '172.16.0.2', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo')).raises(XMLRPC::FaultException.new(1100, "Refresh"))
    xml_rpc2 = mock
    xml_rpc2.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo'))

    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    XMLRPC::Client.expects(:new).with('172.16.0.2', '/1.0').returns(xml_rpc2)
    @mollom.send_command('mollom.testMessage', {:options => 'foo'})
  end
  
  def test_send_command_with_bad_command
    Mollom.any_instance.expects(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo')).raises(XMLRPC::FaultException.new(1000, "Fault String"))
    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    
    assert_raise(Mollom::Error) { @mollom.send_command('mollom.testMessage', {:options => 'foo'}) }
  end
  
  def test_send_command_with_bad_server_and_no_more_available
    Mollom.any_instance.expects(:server_list).returns([{:host => '172.16.0.1', :proto => 'http'}])
    xml_rpc = mock
    xml_rpc.expects(:call).with('mollom.testMessage', has_entry(:options => 'foo')).raises(XMLRPC::FaultException.new(1200, "Redirect"))
    
    XMLRPC::Client.expects(:new).with('172.16.0.1', '/1.0').returns(xml_rpc)
    
    assert_raise(Mollom::NoAvailableServers) { @mollom.send_command('mollom.testMessage', {:options => 'foo'}) }
  end
  
  def test_check_content
    options = {:author_ip => '172.16.0.1', :post_body => 'Lorem Ipsum'}
    
    assert_command 'mollom.checkContent', :with => options, :returns => {"spam" => 1, "quality" => 0.40, "session_id" => 1} do
      cr = @mollom.check_content(options)
      assert cr.ham?
      assert_equal 1, cr.session_id
      assert_equal 0.40, cr.quality
    end
  end
  
  def test_image_captcha
    options = {:author_ip => '172.16.0.1'}
    
    assert_command 'mollom.getImageCaptcha', :with => options, :returns => {'url' => 'http://xmlrpc1.mollom.com:80/a9616e6b4cd6a81ecdd509fa624d895d.png', 'session_id' => 'a9616e6b4cd6a81ecdd509fa624d895d'} do
      @mollom.image_captcha(:author_ip => '172.16.0.1')
    end
  end
  
  def test_audio_captcha
    options = {:author_ip => '172.16.0.1'}
    
    assert_command 'mollom.getAudioCaptcha', :with => options, :returns => {'url' => 'http://xmlrpc1.mollom.com:80/a9616e6b4cd6a81ecdd509fa624d895d.mp3', 'session_id' => 'a9616e6b4cd6a81ecdd509fa624d895d'} do
      @mollom.audio_captcha(options)
    end
  end
  
  def test_valid_captcha
    options = {:session_id => 'a9616e6b4cd6a81ecdd509fa624d895d', :solution => 'foo'}
    
    assert_command 'mollom.checkCaptcha', :with => options, :returns => true do
      assert @mollom.valid_captcha?(options)
    end
  end

  def test_key_ok
    assert_command 'mollom.verifyKey', :returns => true do
      assert @mollom.key_ok?
    end
  end
  
  def test_invalid_key
    assert_command 'mollom.verifyKey', :raises => internal_server_error do
      assert !@mollom.key_ok?
    end
  end
  
  def test_statistics
    assert_command 'mollom.getStatistics', :with => {:type => 'total_accepted'}, :returns => 12 do
      @mollom.statistics(:type => 'total_accepted')
    end
  end
  
  def test_send_feedback
    assert_command 'mollom.sendFeedback', :with => {:session_id => 1, :feedback => 'profanity'} do
      @mollom.send_feedback :session_id => 1, :feedback => 'profanity'
    end
  end
  
  def test_detect_language
    assert_command 'mollom.detectLanguage', :with => {:text => 'Dit is nederlands'}, :returns => [{"confidence"=>0.332, "language"=>"nl"}] do
      assert_equal [{"confidence"=>0.332, "language"=>"nl"}], @mollom.language_for('Dit is nederlands')
    end
  end
  
  def test_api_compatability
    assert @mollom.respond_to? :checkContent
    assert @mollom.respond_to? :getImageCaptcha
    assert @mollom.respond_to? :getAudioCaptcha
    assert @mollom.respond_to? :checkCaptcha
    assert @mollom.respond_to? :verifyKey
    assert @mollom.respond_to? :getStatistics
    assert @mollom.respond_to? :sendFeedback 
    assert @mollom.respond_to? :detectLanguage
  end
  
  private
  def assert_command command, options = {}
    expectation = Mollom.any_instance.expects(:send_command)
    expectation.with do |*arguments|
      arguments.first == command &&
      (!options[:with] || options[:with] == arguments.last)
    end
    expectation.returns(options[:returns]) if options[:returns]
    expectation.raises(options[:raises]) if options[:raises]
    
    yield
  end
  
  def internal_server_error
    XMLRPC::FaultException.new(1000, "Internal server error due to malformed request, or the hamster powering the server died...")
  end
end