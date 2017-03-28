module SubjectsUiHelper
  def visit_images images=nil
    images ||= Image.all
    visit "#{ui_path}/#/images/"
    within("sd-image-selector") do
      expect(page).to have_css(".image-list")
      expect(page).to have_css(".image-list li",:count=>images.count,:wait=>5)
    end
  end

  def image_caption image
    image.caption || "(no caption #{image.id})" 
  end

  def get_linkables image
    things=ThingPolicy::Scope.new(current_user, Thing.not_linked(image)).user_roles(true,false)
    things=ThingPolicy.merge(things)
  end

  def image_editor_loaded! image, expected_linkables=nil
    within("sd-image-editor .image-form") do
      expect(page).to have_css("span.image_id",:text=>image.id,:visible=>false)
      expect(page).to have_css(".image-controls")
      expect(page).to have_css("ul.image-things li span.thing_id",
                              :visible=>false,
                              :count=>ThingImage.where(:image=>image).count,
                              :wait=>5)
      expect(page).to have_css("div.image-existing img",:count=>1,:wait=>5)
      wait_until {find("div.image-existing img")[:complete].to_s=="true"}
    end
    expected_linkables ||= get_linkables(image).size
    if expected_linkables && logged_in?
      expect(page).to have_css(".link-things select option", :count=>expected_linkables)
    end
  end

  def visit_image image
    unless page.has_css?("sd-image-editor .image-form span.image_id", 
                          :text=>image.id,:visible=>false)
      visit "#{ui_path}/#/images/#{image.id}"
    end
    within("sd-image-editor .image-form") do
      expect(page).to have_css("span.image_id",
                               :text=>image.id,:visible=>false,:wait=>5)
      expect(page).to have_css(".image-controls")
      expect(page).to have_css("div.image-existing img",:count=>1,:wait=>5)
    end
  end

  def displayed_caption(image)
    image.caption ? image.caption : "(no caption #{image.id})" 
  end

  def visit_thing thing
    unless page.has_css?("sd-thing-editor .thing-form span.thing_id", 
                          :text=>thing.id,:visible=>false)
      visit "#{ui_path}/#/things/#{thing.id}"
    end
    within("sd-thing-editor .thing-form") do
      expect(page).to have_css("span.thing_id",
                               :text=>thing.id,
                               :visible=>false,
                               :wait=>5)
    end
  end

  def thing_editor_loaded! thing
    expect(page).to have_css("sd-thing-editor")
    within("sd-thing-editor .thing-form") do
      expect(page).to have_css("span.thing_id",:text=>thing.id,
                                               :visible=>false)
      expect(page).to have_css("sd-image-viewer .image-area img",
                              :visible=>false,
                              :count=>ThingImage.where(:thing=>thing).count,
                              :wait=>5)
      wait_until {find("sd-image-viewer .image-area img")[:complete]==true}
      if (page.has_css?("ul.thing-images"))
        expect(page).to have_css("ul.thing-images li span.image_id",
                                :visible=>false,
                                :count=>ThingImage.where(:thing=>thing).count,
                                :wait=>5)
      end
    end
  end

  def visit_things things
    visit "#{ui_path}/#/things/"
    within("sd-thing-selector", :wait=>5) do
      if logged_in? 
        expect(page).to have_css(".thing-list")
        expect(page).to have_css(".thing-list li",:count=>things.count, :wait=>5)
      end
    end
  end

  def visit_subjects
    unless page.has_css?("div.subjects-page")
      visit "#{ui_path}/#/subjects"
    end
    expect(page).to have_css("div.subjects-page")
  end

  def set_origin address, distance=nil
    if page.has_css?("button[title='change-origin']")
      click_button("change-origin")
    end
    fill_in("address-search", :with=>address)
    click_button("lookup-address")
    expect(page).to have_no_button("lookup-address", :wait=>10)
    expect(page).to have_css("span.current-origin", :text=>/.+/)
    fill_in("distance-limit", :with=>distance) if distance
    expect(page).to have_field("distance-limit", :with=>distance)
  end

  def populate_subjects
    @image_distances=[]
    @thing_distances=[]
    shared_images=[]
    user=FactoryGirl.create(:user)
    (1..3).each do 
      thing=FactoryGirl.create(:thing, :with_fields)
      User.find(member[:id]).add_role(Role::MEMBER, thing).save
      if image=shared_images.sample
        thing.thing_images.create(:priority=>5, :image=>image, :creator_id=>user[:id])
      end
      (0..1).each_with_index do |idx|
        image=FactoryGirl.create(:image)
        shared_images << image   if idx>0
        thing.thing_images.create(:priority=>idx, :image=>image, :creator_id=>user[:id])
        @thing_distances << image.distance_from(origin.position) if idx==0
        @image_distances << image.distance_from(origin.position)
      end
      thing_without_primary_image=FactoryGirl.create(:thing)
      thing_without_primary_image.thing_images.create(:priority=>5, 
                                                      :image=>shared_images.sample, 
                                                      :creator_id=>user[:id])
    end
    FactoryGirl.create_list(:image, 3).each do |true_orphan_image|
      @image_distances << true_orphan_image.distance_from(origin.position)
    end
  end

  def select_thing thing_id
    within("sd-area[label='Map']") do #make some Thing current
      find("div.tabs-pane ul li a", :text=>"Things").click
      id=find("ul.things span.thing_id", visible:false, :text=>thing_id)
      id.find(:xpath,"..").click
      expect(page).to have_css("ul.things li.selected")
    end
    thing_id
  end
  def select_image image_id, thing_id=nil
    within("sd-area[label='Subjects']") do #select orphan Image
      find("div.tabs-pane ul li a", :text=>"Images").click
      selector=["ul.images span.image_id", {visible:false, text:image_id}]
      expect(page).to have_css(*selector)
      page.document.synchronize do #re-try query if all() did get all
        id=!thing_id ? first(*selector) : all(*selector).select {|id|
          id.find(:xpath, "..").has_css?("span.thing_id", 
                                        {visible:false, text:thing_id})
        }.first
        id.find(:xpath,"..").click
      end
      expect(page).to have_css("ul.images li.selected")
    end
    image_id
  end
  def get_current_thing_id
    within("sd-area[label='Map']") do #make some Thing current
      find("div.tabs-pane ul li a", :text=>"Things").click
      id=find("div.tabs-pane ul.things li.selected span.thing_id",
                                                visible:false).text(:all)
      id.to_i   if id
    end
  end
  def has_no_current_thing_id
    within("sd-area[label='Map']") do #make some Thing current
      find("div.tabs-pane ul li a", :text=>"Things").click
      expect(page).to have_no_css("div.tabs-pane ul.things li.selected span.thing_id",
                                                visible:false)
    end
  end
  def get_current_image_id
    within("sd-area[label='Subjects']") do #make some Thing current
      find("div.tabs-pane ul li a", :text=>"Images").click
      id=find("div.tabs-pane ul.images li.selected span.image_id",
                                                visible:false).text(:all)
      id.to_i   if id
    end
  end
end
