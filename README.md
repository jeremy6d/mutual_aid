# Richmond Mutual Aid Supply Drive System

The purpose of this system is to streamline operations and broadcast better information about the supply drive efforts.

See the [system tests](https://github.com/jeremy6d/mutual_aid/tree/master/spec/system) for more details on specific workflows.

This app is custom built for Richmond Mutual Aid Distribution. If you'd like to fork this and install it for your own mutual aid efforts, you're welcome to, but there may be some stuff that's hard coded for Richmond. I would love to work with you to white label the software!

## Happy path 
This describes the basic interaction workflow for how the app is used

- HOTLINE WORKER logs call details
  - if call back needed, mark "on_hold" and do not create fulfillments
  - if no call back needed, mark "in_progress" and create 
    - 1 basic fulfillment if supplies needed field is populated
    - special fulfillments for each item in the special requests field
- PACKER visits fulfillment queue
  - all fulfillments are listed in order of urgency, oldest first, by neighborhood
  - packer checks all fulfillments to work on
  - print sheets for all created
  - all fulfillments transition from "pending" to "packed"
- DRIVER creates new delivery
  - adds each fulfillment by number to delivery record and hits "Deliver"
    - (getting rid of the checkmarks in favor of entering the number on the sheet in front of you)
  - Delivery marked "in_transit"
  - all fulfillments marked "on_the_way"
  - Delivery dashboard lists driver name, fulfillments, etc 
- DRIVER marks each fulfillment in delivery "delivered"
- DRIVER marks last fulfillment in delivery "delivered"
  - aid request marked "fulfilled" when all fulfillments "delivered"
  - delivery marked "complete" when all fulfillments "delivered"

## Notes

- we should still have the ability to create ad hoc fulfillments attached to request
- special requests will not be editable after the original creation of the aid request; if special requests need to be added, just create a fulfillment for it
- we'll have a fulfillment dashboard that can separate out special requests from basic ones OR see them combined
- we'll have a dashboard for viewing quantities of special requests across all aid requests so social media folks know what to ask for
- this work does not touch the separation of contacts from aid requests
- note that I'll be shifting data around and there is some risk of data corruption / loss, doing everything I can to mitigate including backups

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
