require "rails_helper"

RSpec.describe School, type: :model do
  it { should belong_to(:local_authority) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:school_type_group) }
  it { should validate_presence_of(:school_type) }
  it { should validate_presence_of(:phase) }

  describe ".search" do
    it "returns schools with a name matching the search term" do
      expect(School.search("Penistone")).to match_array([schools(:penistone_grammar_school)])
    end

    it "returns schools with a postcode matching the search term" do
      expect(School.search("NW2 3RT")).to match_array([schools(:hampstead_school)])
    end

    it "raises an ArgumentError when the search term has fewer than 4 characters" do
      expect(lambda { School.search("Pen") }).to raise_error(ArgumentError, School::SEARCH_NOT_ENOUGH_CHARACTERS_ERROR)
    end

    it "limits the results" do
      stub_const("School::SEARCH_RESULTS_LIMIT", 1)
      expect(School.search("School").count).to eql(1)
    end
  end

  describe "#address" do
    it "returns a formatted address string" do
      school = School.new(
        street: "10 The Street",
        locality: "The locality",
        town: "Town",
        county: "County",
        postcode: "PC1 4TE"
      )
      expect(school.address).to eql("10 The Street, The locality, Town, County, PC1 4TE")
    end

    it "returns a formatted address string when attributes are missing" do
      school = School.new(
        street: "10 The Street",
        locality: "",
        town: "Town",
        county: "County",
        postcode: "PC1 4TE"
      )
      expect(school.address).to eql("10 The Street, Town, County, PC1 4TE")
    end
  end

  describe "#dfe_number" do
    let(:school) do
      build(:school,
        name: "Bash Street School",
        urn: "1234",
        establishment_number: 4567,
        local_authority: build(:local_authority, code: 123))
    end

    it "returns a combination of local authority code and establishment number" do
      expect(school.dfe_number).to eq("123/4567")
    end
  end

  describe "#state_funded?" do
    it "returns true for state funded school type groups" do
      School::STATE_FUNDED_SCHOOL_TYPE_GROUPS.each do |group|
        expect(School.new(school_type_group: group).state_funded?).to eq true
      end
    end

    it "returns false for school type groups that are not state funded" do
      non_state_funded = School::SCHOOL_TYPE_GROUPS.keys.map(&:to_s) - School::STATE_FUNDED_SCHOOL_TYPE_GROUPS

      non_state_funded.each do |phase|
        expect(School.new(school_type_group: phase).state_funded?).to eq false
      end
    end
  end

  describe "#secondary_or_equivalent?" do
    it "returns true for a secondary school" do
      School::SECONDARY_PHASES.each do |phase|
        expect(School.new(phase: phase).secondary_or_equivalent?).to eq true
      end
    end

    it "returns false for schools that are not secondary" do
      non_secondary_phases = School::PHASES.keys.map(&:to_s) - School::SECONDARY_PHASES

      non_secondary_phases.each do |phase|
        expect(School.new(phase: phase).secondary_or_equivalent?).to eq false
      end
    end

    it "returns true for a special school that teaches students over eleven" do
      school = School.new(school_type: :community_special_school, statutory_high_age: 16)
      expect(school.secondary_or_equivalent?).to eq true
    end

    it "returns false for a special school that teaches students eleven or under" do
      school = School.new(school_type: :community_special_school, statutory_high_age: 11)
      expect(school.secondary_or_equivalent?).to eq false
    end

    it "returns false for a non special school that teaches students over eleven" do
      school = School.new(school_type: :community_school, statutory_high_age: 16)
      expect(school.secondary_or_equivalent?).to eq false
    end

    it "returns false for a special school that is a post 16 institution" do
      school = School.new(school_type: :special_post_16_institutions, statutory_high_age: 18)
      expect(school.secondary_or_equivalent?).to eq false
    end

    it "returns true for a alternative provision school that teaches students over eleven" do
      school = School.new(school_type: :pupil_referral_unit, statutory_high_age: 16)
      expect(school.secondary_or_equivalent?).to eq true
    end

    it "returns false for a alternative provision school that teaches students under eleven" do
      school = School.new(school_type: :pupil_referral_unit, statutory_high_age: 11)
      expect(school.secondary_or_equivalent?).to eq false
    end

    it "returns false for a non alternative provision school that teaches students over 11" do
      school = School.new(school_type: :community_school, statutory_high_age: 16)
      expect(school.secondary_or_equivalent?).to eq false
    end
  end
end
