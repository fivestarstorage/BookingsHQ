README.md

This is a project by Riley Martin, aimed at Removals and Transport Companies struggling to manage lots of bookings simultaneously.

This platform gives users the ability to read, create, update and delete bookings in the internal database.

**Functionalities**

1. Adding a Booking
- A user can add a job by clicking on "Create Booking" in the Home Landing Page
- The user can then add a booking name, customer name, description as well as a pickup and dropoff location
- Once a user adds a location, this will be marked on the map with a P (pickup) and D (dropoff) pin.
- ERROR HANDLING: If a user tries to create a booking, and the pickup or dropoff location is not in Australia, then an error will instruct them to change it.
- There is also future capability in the protocol to determine a quote based upon the packageSize, but this is not implemented yet.
- When creating a new booking, the status should be set as 'pending'.

2. Viewing bookings
- I have seeded and initialised some sample bookings for you. However whenever you add a Booking using step 1, you can also view them in the list.
- Click on Manage Bookings - and you can view all of the bookings in the system. These are able to be filtered and are aimed at being as high-level as possible
- When the booking is opened, you should be able to view the booking details, along with the pickup and dropoff location. 
- When clicking on the pickup or dropoff pin on the map, you are able to view the location of the pin via an alert.

Booking states:

Creation (no status) --> Pending --> Confirmed --> Completed

When changing a job from Confirmed to Completed (e.g., finishing a job), there is a bottom sheet which opens, prompting the user to add some notes to the booking. These are set as Booking.completionNotes

Once a Booking has been completed, you are able to view these completionNotes via a standard TextEditor()