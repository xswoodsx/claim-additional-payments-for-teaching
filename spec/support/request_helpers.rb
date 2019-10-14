module RequestHelpers
  def start_claim
    post claims_path, params: {
      claim: {
        eligibility_attributes: {
          qts_award_year: "2016_2017",
        },
      },
    }
  end

  def sign_in_to_admin_with_role(*args)
    stub_dfe_sign_in_with_role(*args)
    post admin_dfe_sign_in_path
    follow_redirect!
  end
end