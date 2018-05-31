class PermitsController < ApplicationController
    # protect_from_forgery prepend: true, with: :exception
    # before_action :authenticate_user!
    before_action :permit_params

    # We need to get current user ID so that it will only see its request
    def index
        if current_user.is_adviser? || current_user.is_facility?
            @permit = Permit.where("adviserStatus= 'pending' OR facilityStatus= 'pending'")
        elsif current_user.is_osa?
            @permit = Permit.where(:osaStatus => "pending")
        # elsif current_user.is_facility?
        #     @permit = Permit.where(:facilityStatus => "pending")
        elsif current_user.is_sao?
            @permit = Permit.where(:saoStatus => "pending")
        elsif current_user.is_student_org?
            @permit = Permit.where(saoStatus: 'pending', org_id: current_user.id)
        end

        @rooms = Room.all
    end

    def approved
        if current_user.is_adviser?
            @permit = Permit.where(:adviserStatus => "approved")
        elsif current_user.is_osa?
            @permit = Permit.where(:osaStatus => "approved")
        elsif current_user.is_facility?
            @permit = Permit.where(:facilityStatus => "approved")
        elsif current_user.is_sao?
            @permit = Permit.where(:saoStatus => "approved")
        elsif current_user.is_student_org?
            @permit = Permit.where(:saoStatus => "approved")
        end
    end

    def rejected
        if current_user.is_adviser?
            @permit = Permit.where(:adviserStatus => "rejected")
        elsif current_user.is_osa?
            @permit = Permit.where(:osaStatus => "rejected")
        elsif current_user.is_facility?
            @permit = Permit.where(:facilityStatus => "rejected")
        elsif current_user.is_sao?
            @permit = Permit.where(:saoStatus => "rejected")
        elsif current_user.is_student_org?
            @permit = Permit.where(:saoStatus => "rejected")
        end
    end

    def new
        @users = User
        @permit = Permit.new
        @rooms = Room.all
        #### Query dapat an adviser tas facility
        #@user = User.find(roles: 'adviser')
        
        
       @users = User.with_role('adviser')
    end

    def create
        @permit = Permit.new(permit_params)

        if @permit.save
            flash[:notice] = "You have successfully created a permit"
            redirect_to permits_index_path
        else
            render 'new'
        end
    end

    def edit
        @permit = Permit.find(params[:id])
        @users = User.all
        @rooms = Room.all
    end

    def update
        @permit = Permit.find(params[:id])
        @permit.update(activity: params[:activity], venue: params[:venue], org_id: params[:org_id], date_needed: params[:date_needed],
                        timefrom: params[:timefrom], timeto: params[:timeto], osaStatus: params[:osaStatus], adviserStatus: params[:adviserStatus],
                        adviser: params[:adviser], facilityStatus: params[:facilityStatus], saoStatus: params[:saoStatus])
        flash[:notice] = "You have successfully updated the permit"
        redirect_to permits_index_path(@permit)
    end

    def destroy
        @permit = Permit.find(params[:id])
        @permit.destroy
        flash[:notice] = "You have successfully deleted the permit"
        redirect_to permits_index_path
    end

    def pdf
        @permit = Permit.find(params[:id])
        respond_to do |format|
        format.html
        format.pdf do
            render :pdf => "report", :template => 'permits/pdf.html.erb'
        end
        format.html
        end
    end

    private
        def permit_params
            params.permit(:activity, :venue, :org_id, :date_needed, :timefrom, :timeto, :adviser, :osaStatus, :adviserStatus, :saoStatus, :facilityStatus)
        end
end
