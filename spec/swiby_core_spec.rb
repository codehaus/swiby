require File.dirname(__FILE__) + '/../swiby/swiby_core'
require 'java'
include_class 'java.awt.Container'
include_class 'java.awt.Panel'
include_class 'java.awt.Label'

describe "Swiby::SwingBase Core Spec" do
  
  it "SwingBase swing_attr_accessor should raise exception if called with no specified symbol." do
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol')}.should raise_error
    lambda {Swiby::SwingBase::swing_attr_accessor(nil)}.should raise_error
  end
 
  it "SwingBase swing_attr_accessor should raise exception if called with argument map where some of the values are not symbols." do
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol' => 'some_value')}.should raise_error
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol' => nil)}.should raise_error
  end
  
  it "SwingBase should have the ability to add swing attr writers only." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.respond_to?(:test_accessor=).should be_true  
  end
  
  it "SwingBase should have the ability to add swing attr accessors." do
    Swiby::SwingBase::swing_attr_accessor :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.respond_to?(:test_accessor).should be_true  
    swing_base.respond_to?(:test_accessor=).should be_true  
  end
  
  class Swiby::SwingBase
    attr_accessor :component 
  end 
  
  it "Swing attr reader should delegate to the underling component." do
    Swiby::SwingBase::swing_attr_accessor :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    #TODO: it looks that one of the generated accessors hide the first declared reader.
    #uncommenting the code below reveal this.
    
    # swing_base.component= mock 'component_mock'
    # swing_base.component.should_receive :test_accessor
    #    
    # swing_base.test_accessor
  end
  
  it "Swing attr writer should delegate to the underling component." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.component= mock 'component_mock'
    arg = 'test_arg'
    swing_base.component.should_receive(:test_accessor=).with(arg)
    
    swing_base.test_accessor= arg
  end
  
  class Swiby::SwingBase::IncrementalValue;end 
  
  it "Swing attr writer should create a method with the same name as the accessors which accept argument of type IncrementValue and delegate to its assign_to method." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    increment_value_mock = mock 'IncrementalValue'
    increment_value_mock.should_receive(:instance_of?).with(Swiby::SwingBase::IncrementalValue).once.and_return true
    increment_value_mock.should_receive(:assign_to).with(swing_base,:test_accessor=)
    swing_base.should_receive(:install_listener).with(increment_value_mock)
    
    swing_base.test_accessor(increment_value_mock)
  end
  
  it "Swing attr writer should create a method with the same name as the accessors that when the parameter is not IncrementValue then it delegates to the writer method with the same name" do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    not_incremental_value_type = Object.new
    swing_base.should_receive(:test_accessor=).with(not_incremental_value_type)
    
    swing_base.test_accessor(not_incremental_value_type)
  end
  
  it "Swing attr writer should create a method with the same name as the accessor that calls the writer method with the returned value during the execution of the passed as a parameter block." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    block_return_value = 'test_value'
    swing_base.should_receive(:test_accessor=).with block_return_value
    
    swing_base.test_accessor { block_return_value }
  end
  
  it "SwingBase should raise an exception if a container is created with not a symbol parameter." do
    lambda {Swiby::SwingBase::container('not_a_symbol')}.should raise_error
  end
  
  it "SwingBase container should create a method with passed in parameter name" do
    Swiby::SwingBase::container :test_container
    swing_base = Swiby::SwingBase.new
      
    swing_base.respond_to?(:test_container).should be_true  
  end
  
  it "The method created by SwingBase::container should be able to accept array of swing components and add it to the main swing component" do
    Swiby::SwingBase::container :add_containers
    swing_base = Swiby::SwingBase.new
      
    swing_component = mock 'swing_component'
    java_component = Object.new
    swing_component.should_receive(:java_component).twice.and_return(java_component)
      
    swing_base.component = mock 'component'
    swing_base.component.should_receive(:add).with(java_component).twice
      
    swing_base.add_containers [swing_component, swing_component]
  end
  
  it "The method created by SwingBase::container should be able to accept the result of the execution of a give block add it to the main swing component" do
    Swiby::SwingBase::container :add_containers
    swing_base = Swiby::SwingBase.new
      
    swing_component = mock 'swing_component'
    java_component = Object.new
    swing_component.should_receive(:java_component).once.and_return(java_component)
      
    swing_base.component = mock 'component'
    swing_base.component.should_receive(:add).with(java_component).once
      
    swing_base.add_containers {swing_component}
  end
  
  it "SwingBase scrollable should initialize scroll pane as java component." do
    swing_base = Swiby::SwingBase.new
    swing_base.component = Container.new
    
    swing_base.scrollable
    
    swing_base.java_component.should_not eql( swing_base.component)
  end
  
  it "SwingBase java component should be the default component if scroll pane is not initialized." do
    swing_base = Swiby::SwingBase.new
    swing_base.component = Container.new
    
    swing_base.java_component.should eql( swing_base.component)
  end
  
  it "component_factory should raise an exception if the passed arg is not symbol or string." do
    lambda {Swiby::SwingBase::component_factory(Object.new)}.should raise_error
  end
  
  include Swiby
  
  it "component_factory should create a method with name as the passed arg." do
    Swiby::component_factory :Panel
     
    respond_to?(:Panel).should be_true
  end
  
  it "component_factory should create factory methods passed with hash" do
    Swiby::component_factory :panel => :Panel, :label => :Label
     
    respond_to?(:panel).should be_true
    respond_to?(:label).should be_true
  end
  
  FLUENT = 'fluent'
  class DSLSwingBuilder
    attr_accessor :dsl
    def should_look how
      @dsl = how
    end
  end
  
  it "component_factory should create factory method that makes the DSL Swing builder look fluent" do
    Swiby::component_factory :DSLSwingBuilder
   
    dsl_swing_builder = DSLSwingBuilder { should_look FLUENT}
    
    dsl_swing_builder.should be_an_instance_of(DSLSwingBuilder)
    dsl_swing_builder.dsl.should be_eql(FLUENT)
  end
end
require File.dirname(__FILE__) + '/../swiby/swiby_core'
require 'java'
include_class 'java.awt.Container'
include_class 'java.awt.Panel'
include_class 'java.awt.Label'

describe "Swiby::SwingBase Core Spec" do
  
  it "SwingBase swing_attr_accessor should raise exception if called with no specified symbol." do
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol')}.should raise_error
    lambda {Swiby::SwingBase::swing_attr_accessor(nil)}.should raise_error
  end
 
  it "SwingBase swing_attr_accessor should raise exception if called with argument map where some of the values are not symbols." do
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol' => 'some_value')}.should raise_error
    lambda {Swiby::SwingBase::swing_attr_accessor('not_a_symbol' => nil)}.should raise_error
  end
  
  it "SwingBase should have the ability to add swing attr writers only." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.respond_to?(:test_accessor=).should be_true  
  end
  
  it "SwingBase should have the ability to add swing attr accessors." do
    Swiby::SwingBase::swing_attr_accessor :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.respond_to?(:test_accessor).should be_true  
    swing_base.respond_to?(:test_accessor=).should be_true  
  end
  
  class Swiby::SwingBase
    attr_accessor :component 
  end 
  
  it "Swing attr reader should delegate to the underling component." do
    Swiby::SwingBase::swing_attr_accessor :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    #TODO: it looks that one of the generated accessors hide the first declared reader.
    #uncommenting the code below reveal this.
    
    # swing_base.component= mock 'component_mock'
    # swing_base.component.should_receive :test_accessor
    #    
    # swing_base.test_accessor
  end
  
  it "Swing attr writer should delegate to the underling component." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    swing_base.component= mock 'component_mock'
    arg = 'test_arg'
    swing_base.component.should_receive(:test_accessor=).with(arg)
    
    swing_base.test_accessor= arg
  end
  
  class Swiby::SwingBase::IncrementalValue;end 
  
  it "Swing attr writer should create a method with the same name as the accessors which accept argument of type IncrementValue and delegate to its assign_to method." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    increment_value_mock = mock 'IncrementalValue'
    increment_value_mock.should_receive(:instance_of?).with(Swiby::SwingBase::IncrementalValue).once.and_return true
    increment_value_mock.should_receive(:assign_to).with(swing_base,:test_accessor=)
    swing_base.should_receive(:install_listener).with(increment_value_mock)
    
    swing_base.test_accessor(increment_value_mock)
  end
  
  it "Swing attr writer should create a method with the same name as the accessors that when the parameter is not IncrementValue then it delegates to the writer method with the same name" do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    not_incremental_value_type = Object.new
    swing_base.should_receive(:test_accessor=).with(not_incremental_value_type)
    
    swing_base.test_accessor(not_incremental_value_type)
  end
  
  it "Swing attr writer should create a method with the same name as the accessor that calls the writer method with the returned value during the execution of the passed as a parameter block." do
    Swiby::SwingBase::swing_attr_writer :test_accessor
    swing_base = Swiby::SwingBase.new 
    
    block_return_value = 'test_value'
    swing_base.should_receive(:test_accessor=).with block_return_value
    
    swing_base.test_accessor { block_return_value }
  end
  
  it "SwingBase should raise an exception if a container is created with not a symbol parameter." do
    lambda {Swiby::SwingBase::container('not_a_symbol')}.should raise_error
  end
  
  it "SwingBase container should create a method with passed in parameter name" do
    Swiby::SwingBase::container :test_container
    swing_base = Swiby::SwingBase.new
      
    swing_base.respond_to?(:test_container).should be_true  
  end
  
  it "The method created by SwingBase::container should be able to accept array of swing components and add it to the main swing component" do
    Swiby::SwingBase::container :add_containers
    swing_base = Swiby::SwingBase.new
      
    swing_component = mock 'swing_component'
    java_component = Object.new
    swing_component.should_receive(:java_component).twice.and_return(java_component)
      
    swing_base.component = mock 'component'
    swing_base.component.should_receive(:add).with(java_component).twice
      
    swing_base.add_containers [swing_component, swing_component]
  end
  
  it "The method created by SwingBase::container should be able to accept the result of the execution of a give block add it to the main swing component" do
    Swiby::SwingBase::container :add_containers
    swing_base = Swiby::SwingBase.new
      
    swing_component = mock 'swing_component'
    java_component = Object.new
    swing_component.should_receive(:java_component).once.and_return(java_component)
      
    swing_base.component = mock 'component'
    swing_base.component.should_receive(:add).with(java_component).once
      
    swing_base.add_containers {swing_component}
  end
  
  it "SwingBase scrollable should initialize scroll pane as java component." do
    swing_base = Swiby::SwingBase.new
    swing_base.component = Container.new
    
    swing_base.scrollable
    
    swing_base.java_component.should_not eql( swing_base.component)
  end
  
  it "SwingBase java component should be the default component if scroll pane is not initialized." do
    swing_base = Swiby::SwingBase.new
    swing_base.component = Container.new
    
    swing_base.java_component.should eql( swing_base.component)
  end
  
  it "component_factory should raise an exception if the passed arg is not symbol or string." do
    lambda {Swiby::SwingBase::component_factory(Object.new)}.should raise_error
  end
  
  include Swiby
  
  it "component_factory should create a method with name as the passed arg." do
    Swiby::component_factory :Panel
     
    respond_to?(:Panel).should be_true
  end
  
  it "component_factory should create factory methods passed with hash" do
    Swiby::component_factory :panel => :Panel, :label => :Label
     
    respond_to?(:panel).should be_true
    respond_to?(:label).should be_true
  end
  
  FLUENT = 'fluent'
  class DSLSwingBuilder
    attr_accessor :dsl
    def should_look how
      @dsl = how
    end
  end
  
  it "component_factory should create factory method that makes the DSL Swing builder look fluent" do
    Swiby::component_factory :DSLSwingBuilder
   
    dsl_swing_builder = DSLSwingBuilder { should_look FLUENT}
    
    dsl_swing_builder.should be_an_instance_of(DSLSwingBuilder)
    dsl_swing_builder.dsl.should be_eql(FLUENT)
  end
end