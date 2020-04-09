class AuthorizedOnlyController < ApplicationController
  before_action :authenticate_volunteer!
end
