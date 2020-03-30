custom_formats = { date_only: '%m/%d/%Y',
                   date_and_time: '%m/%d/%Y %I:%M %p',
                   time_only: '%I:%M %p' ,
                   formal: '%a %b %d',
                   searchable: '%A %B %d %m/%d/%Y'}

Time::DATE_FORMATS.merge! custom_formats
Date::DATE_FORMATS.merge! custom_formats
