#!/usr/bin/env ruby
# frozen_string_literal: true

Volunteer.all.each do |v|
  v.password = "password"
  v.password_confirmation = "password"
  v.save(touch: false)
end
