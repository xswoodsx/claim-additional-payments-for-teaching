class SubmissionsController < ApplicationController
  include PartOfClaimJourney

  def create
    if current_claim.submit!
      ClaimMailer.submitted(current_claim).deliver_later
      redirect_to claim_path("confirmation")
    else
      render "claims/check_your_answers"
    end
  end
end
