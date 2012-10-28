class PdfOfferConfirmation < PdfOffer

  def initialize(rental, text = nil)
    super rental, conv('A U F T R A G S B E S T Ä T I G U N G')
  end

  def top_text
    @process.evaluated_offer_confirmation_top_text
  end

  def bottom_text
    @process.evaluated_offer_confirmation_bottom_text
  end

end
