RSpec.describe Base::Project do
  it "has a version number" do
    expect(Base::Project::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
