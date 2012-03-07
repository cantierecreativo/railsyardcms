require 'spec_helper'

describe Theme do

  describe "#all" do
    it "returns the available themes" do
      theme_path = "foo/bar/"
      theme = stub(:valid? => true)
      Theme.stubs(:available_theme_directories).returns([theme_path])
      Theme.stubs(:load).with("foo/bar/theme_conf.yml").returns(theme)
      Theme.all.should == [ theme ]
    end

    it "raises Theme::Invalid if one of the themes is not valid" do
      theme_path = "foo/bar/"
      theme = stub(:valid? => false)
      Theme.stubs(:available_theme_directories).returns([theme_path])
      Theme.stubs(:load).with("foo/bar/theme_conf.yml").returns(theme)
      lambda { Theme.all }.should raise_error Theme::Invalid
    end
  end

  describe "#find!" do
    it "returns the theme by identifier" do
      theme = stub(:identifier => "test")
      Theme.stubs(:all).returns([ theme ])
      Theme.find!(:test).should == theme
    end
    it "raises Theme::NotFound if cannot find it" do
      Theme.stubs(:all).returns([])
      lambda { Theme.find!(:test) }.should raise_error Theme::NotFound
    end
  end

  describe "#load" do
    it "initializes a new theme from a Yaml config file" do
      theme = stub
      theme_attrs = stub_everything
      YAML.stubs(:load_file).with("/path/config.yml").returns(theme_attrs)
      Theme.stubs(:new).with(theme_attrs).returns(theme)
      Theme.load("/path/config.yml").should == theme
    end
  end

  describe "#available_theme_directories" do
    it "returns the available Railsyard themes" do
      Theme.publicize_methods do
        themes_container_path = Rails.root.join("spec/fixtures/themes")
        themes = Theme.available_theme_directories(themes_container_path)
        themes.map { |path| File.basename(path) }.should =~ ["foo", "bar"]
      end
    end
  end

  describe ".layouts" do
    it "returns an array of Layouts" do
      layout_attrs = stub
      layout = stub
      Layout.stubs(:new).with(layout_attrs).returns(layout)
      Theme.new(:layouts => [layout_attrs]).layouts.first.should == layout
    end
  end

  describe ".find_layout!" do
    it "returns the layout with the specified identifier" do
      layout = stub(:identifier => "foo")
      theme = Theme.new
      theme.stubs(:layouts).returns([ layout ])
      theme.find_layout!(:foo).should == layout
    end

    it "raises a Theme::LayoutNotFound if it doesn't exist" do
      theme = Theme.new
      theme.stubs(:layouts).returns([])
      lambda { theme.find_layout!(:foo) }.should raise_error Theme::LayoutNotFound
    end
  end

  describe "acceptance on a valid theme Yaml configuration file" do
    it "should not throw validation problems" do
      theme = Theme.load(Rails.root.join("spec/fixtures/themes/bar/theme_conf.yml"))
      theme.should be_valid
      theme.identifier.should == "bar"
      theme.title.should == "title"
      theme.author.should == "author"
      theme.description.should == "description"

      layout = theme.find_layout!(:layout_id)
      layout.identifier.should == "layout_id"
      layout.title.should == "layout_title"
      layout.view.should == "view"
    end
  end

end
