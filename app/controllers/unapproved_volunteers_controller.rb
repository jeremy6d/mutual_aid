class UnapprovedVolunteersController < AuthorizedOnlyController
  def index
    @volunteers = Volunteer.where(approved_by: nil)
  end

  def update
    if Volunteer.where(id: params[:volunteer_ids]).update(approved_by: current_volunteer)
      redirect_to aid_requests_path, notice: "Approvals complete"
    else
      flash[:error] = "There was a problem approving volunteers"
      render :index
    end
  end
end
