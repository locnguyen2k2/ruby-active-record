class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include SessionHelper
  include ExceptionResponse

  protect_from_forgery

  after_action :verify_policy_scoped, only: [ :index ]
  after_action :verify_authorized, except: :index

  serialization_scope :options

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  def unauthorized(err)
    e = MessageData::UNAUTHORIZED
    policy_name = err.policy.class.to_s.underscore
    render json: {
      message: "#{e[:message]} of #{policy_name} on #{err.query} ",
      success: false
    }, status: e[:status] ||= 200
  end
end
