require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "SubjectLayouts", type: :feature, js: true do
  include_context "db_cleanup"
  include SubjectsUiHelper
  before(:each) do
    visit_subjects
  end

  describe "subjects page" do
    it "displays subject page" do
      expect(page).to have_css(".subjects-page")
    end
    it "has subjects dropdown active" do
      find("#main-menubar ul.nav li.dropdown a",:text=>"Go To").click
      expect(page).to have_css("li.active",:text=>"Subjects")
    end
    it "has areas" do
      expect(page).to have_css("sd-areas")
    end
  end

  shared_examples "area" do |area, tabs|
    it "has #{area[:label]} area component" do
      within("sd-areas") do
        expect(page).to have_css("div.areas-pane")
        expect(page).to have_css("sd-area[label='#{area[:label]}']")
        within("sd-area[label='#{area[:label]}']") do
          expect(page).to have_css("div.area-pane")
        end
      end
    end

    it "#{area[:label]} area has tabs" do
      within("sd-area[label='#{area[:label]}'] div.area-pane") do
        expect(page).to have_css("sd-tabs") 

        within("sd-tabs") do
          expect(page).to have_css("div.tabs-pane")

          within("div.tabs-pane") do
            expect(page).to have_css("ul.tab-label")  #a list of labels
            expect(page).to have_css("div.tab-content") #a div with content

            tabs.each_with_index do |tab,idx|
              within ("ul.tab-label") do  #list of labels has our tab.label
                expect(page).to have_css("li a ", :text=>tab[:label])
              end

              within("div.tab-content") do #content has our component for tab.label
                expect(page).to have_css("sd-tab[label='#{tab[:label]}']")
                within("sd-tab[label='#{tab[:label]}']") do
                  expect(page).to have_css("div.tab-pane", :visible=>idx==0)
                end
              end
            end
          end
        end
      end
    end

    it "#{area[:label]} area is collapsable" do
      find("sd-area[label='#{area[:label]}'] div.area-pane")
      expect(page).to have_no_css("div.areas-pane ul.area li a", :text=>area[:label])

      within("sd-area[label='#{area[:label]}']") do
        expect(page).to have_css("div.area-pane") 
        find("div.area-pane input[name='collapse-area']").click
        expect(page).to have_no_css("div.area-pane") 
      end
      expect(page).to have_css("div.areas-pane ul.area li a", :text=>area[:label])
    end

    it "#{area[:label]} area is expandable" do
      find("sd-area[label='#{area[:label]}'] div.area-pane")
      within("sd-area[label='#{area[:label]}']") do
        find("div.area-pane input[name='collapse-area']").click  #collapse
      end
      expect(page).to have_css("div.areas-pane ul.area li a", :text=>area[:label])
      find("div.areas-pane li a", :text=>area[:label]).click   #expand
      find("sd-area[label='#{area[:label]}'] div.area-pane")
      expect(page).to have_no_css("div.areas-pane ul.area li a", :text=>area[:label])
    end
  end

  describe "Subjects Area" do
    it_behaves_like "area", {label:"Subjects"}, 
                           [{label:"Things"},
                            {label:"Images"}]
  end

  describe "Details Area" do
    it_behaves_like "area", {label:"Details"},
                           [{label:"Thing"},
                            {label:"Image"}]
  end

  describe "Map Area" do
    it_behaves_like "area", {label:"Map"},
                           [{label:"Map"},
                            {label:"Things"},
                            {label:"Images"},
                            {label:"Thing"},
                            {label:"Image"}]
  end

  describe "area sides" do
    it "displays right and left" do
      ["left", "right"].each do |pos|
        expect(page).to have_css("sd-areas div.areas-#{pos}")
        expect(page).to have_no_css("sd-areas div.areas-#{pos}.ng-hide")
        within("sd-areas div.areas-#{pos}") do
          expect(page).to have_css("sd-area:nth-child(1)")
        end
      end
    end

    it "displays right fullsize when left hidden" do
      expect(page).to have_css("div.areas-left.col-sm-6")
      expect(page).to have_css("div.areas-right.col-sm-6")
      ["Subjects","Details"].each do |area|
        within("sd-area[label='#{area}']") do
          find("div.area-pane input[name='collapse-area']").click  #collapse
        end
      end
      expect(page).to have_no_css("sd-areas div.areas-left")
      expect(page).to have_css("sd-areas div.areas-right.col-sm-12")
    end

    it "displays left fullsize when right hidden" do
      expect(page).to have_css("div.areas-left.col-sm-6")
      expect(page).to have_css("div.areas-right.col-sm-6")
      ["Map"].each do |area|
        within("sd-area[label='#{area}']") do
          find("div.area-pane input[name='collapse-area']").click  #collapse
        end
      end
      expect(page).to have_no_css("sd-areas div.areas-right",:wait=>3)
      expect(page).to have_css("sd-areas div.areas-left.col-sm-12")
    end

    it "expands upper left when lower left hidden" do
      expect(page).to have_css("sd-area[label='Subjects'] div.area-pane") 
      expect(page).to have_css("sd-area[label='Details'] div.area-pane") 
      expect(page).to have_no_css("sd-area[label='Subjects'] div.area-pane.expanded") 
      expect(page).to have_no_css("sd-area[label='Details'] div.area-pane.expanded") 

      find("sd-area[label='Details'] input[name='collapse-area']").click  #collapse
      expect(page).to have_no_css("sd-area[label='Details'] div.area-pane",:wait=>3) 
      expect(page).to have_css("sd-area[label='Subjects'] div.area-pane.expanded") 
    end

    it "expands lower left when upper left hidden" do
      expect(page).to have_css("sd-area[label='Subjects'] div.area-pane") 
      expect(page).to have_css("sd-area[label='Details'] div.area-pane") 
      expect(page).to have_no_css("sd-area[label='Subjects'] div.area-pane.expanded") 
      expect(page).to have_no_css("sd-area[label='Details'] div.area-pane.expanded") 

      find("sd-area[label='Subjects'] input[name='collapse-area']").click  #collapse
      expect(page).to have_no_css("sd-area[label='Subjects'] div.area-pane",:wait=>3) 
      expect(page).to have_css("sd-area[label='Details'] div.area-pane.expanded") 
    end
  end
end
