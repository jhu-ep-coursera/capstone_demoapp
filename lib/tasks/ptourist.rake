namespace :ptourist do
  MEMBERS=["mike","carol","alice","greg","marsha","peter","jan","bobby","cindy"]
  ADMINS=["mike","carol"]
  ORIGINATORS=["carol","alice"]
  BOYS=["greg","peter","bobby"]
  GIRLS=["marsha","jan","cindy"]

  def user_name first_name
    last_name = (first_name=="alice") ? "nelson" : "brady"
    "#{first_name} #{last_name}".titleize
  end
  def user_email first_name
    "#{first_name}@bbunch.org"
  end
  def user first_name
    User.find_by(:email=>user_email(first_name))
  end

  def users first_names
    first_names.map {|fn| user(fn) }
  end
  def first_names users
    users.map {|user| user.email.chomp("@bbunch.org") }
  end
  def admin_users
     @admin_users ||= users(ADMINS)
  end
  def originator_users
     @originator_users ||= users(ORIGINATORS)
  end
  def member_users
     @member_users ||= users(MEMBERS)
  end
  def boy_users
    @boy_users ||= users(BOYS)
  end
  def girl_users
    @girl_users ||= users(GIRLS)
  end
  def mike_user
    @mike_user ||= user("mike")
  end

  def create_image organizer, img
    puts "building image for #{img[:caption]}, by #{organizer.name}"
    image=Image.create(:creator_id=>organizer.id,:caption=>img[:caption])
    organizer.add_role(Role::ORGANIZER, image).save
  end
  def create_thing thing, organizer, members, images
    thing=Thing.create!(thing)
    organizer.add_role(Role::ORGANIZER, thing).save
    m=members.map { |member|
      unless (member.id==organizer.id || member.id==mike_user.id)
        member.add_role(Role::MEMBER, thing).save
        member
      end
    }.select {|r| r}
    puts "added organizer for #{thing.name}: #{first_names([organizer])}"
    puts "added members for #{thing.name}: #{first_names(m)}"
    images.each do |img|
      puts "building image for #{thing.name}, #{img[:caption]}, by #{organizer.name}"
      image=Image.create(:creator_id=>organizer.id,:caption=>img[:caption])
      organizer.add_role(Role::ORGANIZER, image).save
      ThingImage.new(:thing=>thing, :image=>image, 
                     :creator_id=>organizer.id)
                .tap {|ti| ti.priority=img[:priority] if img[:priority]}.save!
    end
  end

  desc "reset all data"
  task reset_all: [:users,:subjects] do
  end

  desc "deletes things, images, and links" 
  task delete_subjects: :environment do
    puts "removing #{Thing.count} things and #{ThingImage.count} thing_images"
    puts "removing #{Image.count} images"
    DatabaseCleaner[:active_record].clean_with(:truncation, {:except=>%w[users]})
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  desc "delete all data"
  task delete_all: [:delete_subjects] do
    puts "removing #{User.count} users"
    DatabaseCleaner[:active_record].clean_with(:truncation, {:only=>%w[users]})
  end

  desc "reset users"
  task users: [:delete_all] do
    puts "creating users: #{MEMBERS}"

    MEMBERS.each_with_index do |fn,idx|
     User.create(:name  => user_name(fn),
                 :email => user_email(fn),
                 :password => "password#{idx}")
    end

    admin_users.each do |user|
      user.roles.create(:role_name=>Role::ADMIN)
    end

    originator_users.each do |user|
      user.add_role(Role::ORIGINATOR, Thing).save
    end

    puts "users:#{User.pluck(:name)}"
  end

  desc "reset things, images, and links" 
  task subjects: [:users] do
    puts "creating things, images, and links"

    thing={:name=>"B&O Railroad Museum",
    :description=>"Discover your adventure at the B&O Railroad Museum in Baltimore, Maryland. Explore 40 acres of railroad history at the birthplace of American railroading. See, touch, and hear the most important American railroad collection in the world! Seasonal train rides for all ages.",
    :notes=>"Trains rule, boats and cars drool"}
    organizer=user("alice")
    members=member_users
    images=[
    {:path=>"db/bta/image001_original.jpg",
     :caption=>"Front of Museum Restored: 1884 B&O Railroad Museum Roundhouse",
     :lng=>-76.6327453,
     :lat=>39.2854217,
     :priority=>0},
    {:path=>"db/bta/image002_original.jpg",
     :caption=>"Roundhouse Inside: One-of-a-Kind Railroad Collection inside the B&O Roundhouse",
     :lng=>-76.6327453,
     :lat=>39.2854217},
    {:path=>"db/bta/image003_original.jpg",
     :caption=>"40 acres of railroad history at the B&O Railroad Museum",
     :lng=>-76.6327453,
     :lat=>39.2854217},
    ]
    create_thing thing, organizer, members, images

    thing={:name=>"Baltimore Water Taxi",
    :description=>"The Water Taxi is more than a jaunt across the harbor; it’s a Baltimore institution and a way of life. Every day, thousands of residents and visitors not only rely on us to take them safely to their destinations, they appreciate our knowledge of the area and our courteous service. And every day, hundreds of local businesses rely on us to deliver customers to their locations.  We know the city. We love the city. We keep the city moving. We help keep businesses thriving. And most importantly, we offer the most unique way to see Baltimore and provide an unforgettable experience that keeps our passengers coming back again and again.",
    :notes=>"No on-duty pirates, please"}
    organizer=user("carol")
    members=member_users
    images=[
    {:path=>"db/bta/DSC_5358.jpg",
     :caption=>"Boat at Fort McHenry",
     :lng=>-76.578519,
     :lat=>39.265882},
    {:path=>"db/bta/DSC_5393.jpg",
     :caption=>"Boat heading in to Fell's Point",
     :lng=>-76.593026,
     :lat=>39.281676},
    {:path=>"db/bta/DSC_5441.jpg",
     :caption=>"Boat at Harborplace",
     :lng=>-76.611449,
     :lat=>39.285887,
     :priority=>0},
    {:path=>"db/bta/DSC_5469.jpg",
     :caption=>"Boat passing Pier 5",
     :lng=>-76.605206,
     :lat=>39.284038}
    ]
    create_thing thing, organizer, members, images

    thing={:name=>"Rent-A-Tour",
    :description=>"Professional guide services and itinerary planner in Baltimore, Washington DC, Annapolis and the surronding region",
    :notes=>"Bus is clean and ready to roll"}
    organizer=user("greg")
    members=boy_users
    images=[
    {:path=>"db/bta/image004_original.jpg",
     :caption=>"Overview",
     :lng=>nil,
     :lat=>nil
     },
    {:path=>"db/bta/image005_original.jpg",
     :caption=>"Roger Taney Statue",
     :lng=>-76.615686,
     :lat=>39.297953,
     :priority=>0
     }
    ]
    create_thing thing, organizer, members, images

    thing={:name=>"Holiday Inn Timonium",
    :description=>"Group friendly located just a few miles north of Baltimore's Inner Harbor. Great neighborhood in Baltimore County",
    :notes=>"Early to bed, early to rise"}
    organizer=user("alice")
    members=member_users
    images=[
    {:path=>"db/bta/hitim-001.jpg",
     :caption=>"Hotel Front Entrance",
     :lng=>-76.64285450000001, 
     :lat=>39.454538,
     :priority=>0
     }
    ]
    create_thing thing, organizer, members, images

    thing={:name=>"National Aquarium",
    :description=>"Since first opening in 1981, the National Aquarium has become a world-class attraction in the heart of Baltimore. Recently celebrating our 35th Anniversary, we continue to be a symbol of urban renewal and a source of pride for Marylanders. With a mission to inspire the world’s aquatic treasures, the Aquarium is consistently ranked as one of the nation’s top aquariums and has hosted over 51 million guests since opening. A study by the Maryland Department of Economic and Employment Development determined that the Aquarium annually generates nearly $220 million in revenues, 2,000 jobs, and $6.8 million in State and local taxes. It was also recently named one of Baltimore’s Best Places to Work! In addition to housing nearly 20,000 animals, we have countless science-based education programs and hands-on conservation projects spanning from right here in the Chesapeake Bay to abroad in Costa Rica. Once you head inside, The National Aquarium has the ability to transport you all over the world in a matter of hours to discover hundreds of incredible species. From the Freshwater Crocodile in our Australia: Wild Extremes exhibit all the way to a Largetooth Sawfish in the depths of Shark Alley. Recently winning top honors from the Association of Zoos and Aquariums for outstanding design, exhibit innovation and guest engagement, we can’t forget about Living Seashore; an exhibit where guests can touch Atlantic stingrays, Horseshoe crabs, and even Moon jellies if they wish! It is a place for friends, family, and people from all walks of life to come and learn about the extraordinary creatures we share our planet with. Through education, research, conservation action and advocacy, the National Aquarium is truly pursuing a vision to change the way humanity cares for our ocean planet.",
    :notes=>"Remember to water the fish"}
    organizer=user("carol")
    members=member_users
    images=[
    {:path=>"db/bta/naqua-001.jpg",
     :caption=>"National Aquarium buildings",
     :lng=>-76.6083, 
     :lat=>39.2851,
     :priority=>0
     },
    {:path=>"db/bta/naqua-002.jpg",
     :caption=>"Blue Blubber Jellies",
     :lng=>-76.6083, 
     :lat=>39.2851,
     },
    {:path=>"db/bta/naqua-003.jpg",
     :caption=>"Linne's two-toed sloths",
     :lng=>-76.6083, 
     :lat=>39.2851,
     },
    {:path=>"db/bta/naqua-004.jpg",
     :caption=>"Hosting millions of students and teachers",
     :lng=>-76.6083, 
     :lat=>39.2851,
     }
    ]
    create_thing thing, organizer, members, images

    thing={:name=>"Hyatt Place Baltimore",
    :description=>"The New Hyatt Place Baltimore/Inner Harbor, located near Fells Point, offers a refreshing blend of style and innovation in a neighborhood alive with cultural attractions, shopping and amazing local restaurants. 

Whether you’re hungry, thirsty or bored, Hyatt Place Baltimore/Inner Harbor has something to satisfy your needs. Start your day with our free a.m. Kitchen Skillet™, featuring hot breakfast sandwiches, breads, cereals and more. Visit our 24/7 Gallery Market for freshly packaged grab n’ go items, order a hot, made-to-order appetizer or sandwich from our 24/7 Gallery Menu or enjoy a refreshing beverage from our Coffee to Cocktails Bar.
 
Work up a sweat in our 24-hour StayFit Gym, which features Life Fitness® cardio equipment and free weights. Then, float and splash around in our indoor pool, open year-round for your relaxation. There’s plenty of other spaces throughout our Inner Harbor hotel for you to chill and socialize with other guests. For your comfort and convenience, all Hyatt Place hotels are smoke-free.
"}
    organizer=user("marsha")
    members=girl_users
    images=[
    {:path=>"db/bta/hpm-001.jpg",
     :caption=>"Hotel Front Entrance",
     :lng=>-76.5987, 
     :lat=>39.2847,
     :priority=>0
     },
    {:path=>"db/bta/hpm-002.jpg",
     :caption=>"Terrace",
     :lng=>-76.5987, 
     :lat=>39.2847,
     :priority=>1
     },
    {:path=>"db/bta/hpm-003.jpg",
     :caption=>"Cozy Corner",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-004.jpg",
     :caption=>"Fitness Center",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-005.jpg",
     :caption=>"Gallery Area",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-006.jpg",
     :caption=>"Harbor Room",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-007.jpg",
     :caption=>"Indoor Pool",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-008.jpg",
     :caption=>"Lobby",
     :lng=>-76.5987, 
     :lat=>39.2847
     },
    {:path=>"db/bta/hpm-009.jpg",
     :caption=>"Specialty King",
     :lng=>-76.5987, 
     :lat=>39.2847
     }
    ]
    create_thing thing, organizer, members, images

    organizer=user("peter")
    image= {:path=>"db/bta/aquarium.jpg",
     :caption=>"Aquarium",
     :lng=>-76.6083, 
     :lat=>39.2851
     }
    create_image organizer, image

    organizer=user("jan")
    image= {:path=>"db/bta/bromo_tower.jpg",
     :caption=>"Bromo Tower",
     :lng=>-76.6228645, 
     :lat=>39.2876736
     }
    create_image organizer, image

    organizer=user("bobby")
    image= {:path=>"db/bta/federal_hill.jpg",
     :caption=>"Federal Hill",
     :lng=>-76.6152507,
     :lat=>39.2780092
     }
    create_image organizer, image

    organizer=user("alice")
    image= {:path=>"db/bta/row_homes.jpg",
     :caption=>"Row Homes",
     :lng=>-76.6152153,
     :lat=>39.3149715
     }
    create_image organizer, image

    organizer=user("alice")
    image= {:path=>"db/bta/skyline_water_level.jpg",
     :caption=>"Skyline Water Level",
     :lng=>-76.6284366, 
     :lat=>39.2780493
     }
    create_image organizer, image

    organizer=user("bobby")
    image= {:path=>"db/bta/skyline.jpg",
     :caption=>"Skyline",
     :lng=>-76.6138132,
     :lat=>39.2801504
     }
    create_image organizer, image

    organizer=user("marsha")
    image= {:path=>"db/bta/visitor_center.jpg",
     :caption=>"Visitor Center",
     :lng=>-76.6155792, 
     :lat=>39.28565
     }
    create_image organizer, image

    organizer=user("greg")
    image= {:path=>"db/bta/world_trade_center.jpg",
     :caption=>"World Trade Center",
     :lng=>-76.6117195,
     :lat=>39.2858057
     }
    create_image organizer, image

    puts "#{Thing.count} things created and #{ThingImage.count("distinct thing_id")} with images"
    puts "#{Image.count} images created and #{ThingImage.count("distinct image_id")} for things"
  end

end
