# Richmond Mutual Aid Supply Drive System

The purpose of this system is to streamline operations and broadcast better information about the supply drive efforts.

See the tests for more details!

## Happy path

(Another request 2 was logged and fulfillment 2 was created for it previously)

User HOTLINE enters request 1 information and submits
  - information is persisted to the database
  - request is marked "unfulfilled"
  - redirects to the new request form
  - shows a flash saying message entered

User PACKER creates a fulfillment 1
  - system should print a fulfillment sheet
    - sheet has map of location and streetview
    - sheet has details of request and fulfillment 1
    - sheet lists total number of bags
    - sheet displays unique id of request and fulfillment 1
  - fufillment form should have all details for request available

PACKER packs the bag
PACKER attaches a photo of a list of contents
PACKER enters adds a bag and prints another sheet
- system should print another fulfillment sheet

PACKER attaches sheets to bags and marks fulfillment 1 "packed"
- redirects to request view
  - request is marked "in progress"
  - fulfillment 1 and "packed" status shown in list
  - thumbnail of list

User DRIVER picks up this fulfillment and another, picks each in the delivery list, and submits them as a new delivery attached to him
  - delivery view shown with fufillment 1
  - fulfillment 1 is marked "on the way"
  - fulfillment 2 is marked "on the way"

DRIVER makes delivery and marks fulfillment 1 "delivered"
  - fulfillment 1 is marked "delivered"
  - request 1 is marked "complete"
  - fulfillement 2 details come up on screen

DRIVER makes delivery and marks fulfillment 2 "delivered"
  - fulfillment 2 is marked "delivered"
  - request 2 is marked "complete"
  - delivery complete screen shown

User INVENTORY pulls up fulfillment in outgoing inventory queue
  - fulfillment is displayed with all fulfillment details

INVENTORY marks the fulfillment "reconciled"


<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
