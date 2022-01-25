require "application_system_test_case"

class InterviewsTest < ApplicationSystemTestCase
  setup do
    @interview = interviews(:one)
  end

  test "visiting the index" do
    visit interviews_url
    assert_selector "h1", text: "Interviews"
  end

  test "should create interview" do
    visit interviews_url
    click_on "New interview"

    fill_in "Code", with: @interview.code
    fill_in "End time", with: @interview.end_time
    fill_in "Note", with: @interview.note
    check "Result" if @interview.result
    fill_in "Start time", with: @interview.start_time
    click_on "Create Interview"

    assert_text "Interview was successfully created"
    click_on "Back"
  end

  test "should update Interview" do
    visit interview_url(@interview)
    click_on "Edit this interview", match: :first

    fill_in "Code", with: @interview.code
    fill_in "End time", with: @interview.end_time
    fill_in "Note", with: @interview.note
    check "Result" if @interview.result
    fill_in "Start time", with: @interview.start_time
    click_on "Update Interview"

    assert_text "Interview was successfully updated"
    click_on "Back"
  end

  test "should destroy Interview" do
    visit interview_url(@interview)
    click_on "Destroy this interview", match: :first

    assert_text "Interview was successfully destroyed"
  end
end
