class ListingMailer < ApplicationMailer

  def listing_created listing
    @listing = listing
    mail(to: 'info@ethicaltree.com', subject: "New Listing Created: #{listing.title}")
  end

end
