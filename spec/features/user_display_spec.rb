feature "User display" do

  before do |example|
    unless example.metadata[:skip_before]
      sign_up
    end
  end

  scenario "after logging in, the user can view their profile", js: true do
    click_button("opensidebar")
    expect(page).to have_content("tester")
    expect(page).to have_content("Status:")
    expect(page).to have_content("Overall Rank:")
  end

end