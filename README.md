# GuestDocumentUploadFC

This is a small extension to the [All Onboard Starter Pack](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FMiQpUAL), that allows the Document Upload component to be used in Unauthenticated / Guest User flows in Experience Cloud sites.  This extension creates a new (Aura) component called DocumentUpload2 (original!) that can be dropped in instead.  It mostly just changes the sharing rules in the Apex controller to allow it to run "without sharing", allowing guest users to see the preview of the uploaded documents.  As a bonus, it populates a new custom field on the ContentVersion object with the configured Document Type for the uploaded document (Licence, Passport, etc.)

The Starter Pack managed package **must** be installed before installing this component.  The component refers to the custom namespace for that package, and won't install without it being present.
