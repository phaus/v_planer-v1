class PdfOffer < PdfLetter

  def initialize(rental, text = nil)
    @process = rental
    super @process.sender, @process.client, (text || conv('A N G E B O T')), ''
    @top_header_fields[1]    = conv('VG-Nr.')
    @bottom_header_fields[1] = @process.process_no
    @top_header_fields[2]    = conv('Bearbeiter')
    @bottom_header_fields[2] = @process.user.full_name
  end

  def selling?
    @process.is_a? Selling
  end

  def rental?
    @process.is_a? Rental
  end

  def top_text
    @process.evaluated_offer_top_text
  end

  def bottom_text
    @process.evaluated_offer_bottom_text
  end

  def main_content
    @cw = [10.0, 100.0, 20.0, 14.0, 24.0] # cell widths

    self.set_font 'Helvetica', '', 10.0
    self.write 4.5, conv(self.top_text)
    self.ln 9.0

    draw_rental_device_items  if rental? and @process.device_items.any?
    draw_selling_device_items if selling? and @process.device_items.any?
    draw_device_subtotal      if @process.device_items.any? and @process.service_items.any?
    draw_service_items        if @process.service_items.any?

    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('Gesamtsumme:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[4], 6.0, money(@process.sum), 'B', 0, 'R', 0
    self.ln

    unless @process.client_discount == 0.0
      self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
      self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
      self.cell @cw[2], 6.0, conv('Kundenrabatt:'), '', 0, 'R', 0
      self.cell @cw[3], 6.0, conv(sprintf('%.2f%%', @process.client_discount_percent)), 0, 0, 'R', 0
      self.cell @cw[4], 6.0, money(-@process.client_discount), '', 0, 'R', 0
      self.ln
    end

    unless @process.discount == 0.0
      self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
      self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
      self.cell @cw[2], 6.0, conv('Auftragsrabatt:'), '', 0, 'R', 0
      self.cell @cw[3], 6.0, '', 0, 0, 'R', 0
      self.cell @cw[4], 6.0, money(-@process.discount), '', 0, 'R', 0
      self.ln
    end

    self.set_line_width 0.6
    self.set_font 'Helvetica', 'B'
    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('Total Netto:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, '', 0, 0, 'R', 0
    self.cell @cw[4], 6.0, money(@process.net_total_price), 'B', 0, 'R', 0
    self.ln

    self.set_font 'Helvetica', ''
    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('MwSt:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, conv('19.0%'), 0, 0, 'R', 0
    self.cell @cw[4], 6.0, money(@process.vat), '', 0, 'R', 0
    self.ln

    self.set_font 'Helvetica', 'B'
    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('Total Brutto:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, '', 0, 0, 'R', 0
    self.cell @cw[4], 6.0, money(@process.gross_total_price), 'B', 0, 'R', 0

    self.ln 12.0
    self.set_font 'Helvetica', '', 10.0
    self.write 4.5, conv(self.bottom_text)
  end

  def draw_rental_device_items
    self.set_font 'Helvetica', 'B', 11.0
    self.write 5.0, conv('Artikel')
    self.ln 9.0
    self.set_font 'Helvetica', '', 9.0

    self.set_text_color 0
    self.set_draw_color 16, 16, 50
    self.set_line_width 0.3
    self.set_font 'Helvetica', 'B'
    self.cell @cw[0], 6.0, conv('Anz.'),        'B', 0, 'L', 1
    self.cell @cw[1], 6.0, conv('Artikel'),     'B', 0, 'C', 1
    self.cell @cw[2], 6.0, conv('Tagespreis'),  'B', 0, 'R', 1
    self.cell @cw[3], 6.0, conv('Dauer'),       'B', 0, 'R', 1
    self.cell @cw[4], 6.0, conv('Gesamtpreis'), 'B', 0, 'R', 1
    self.set_font 'Helvetica', ''
    self.ln

#     self.set_fill_color 240, 240, 256
    @process.device_items.each do |elm|
      self.cell @cw[0], 6.0, elm.count.to_s + ' x',                  0, 0, 'R', 1
      self.cell @cw[1], 6.0, conv(elm.product.full_name),            0, 0, 'L', 1
      self.cell @cw[2], 6.0, money(elm.unit_price),    0, 0, 'R', 1
      self.cell @cw[3], 6.0, sprintf('%.2f d', elm.billed_duration), 0, 0, 'R', 1
      self.cell @cw[4], 6.0, money(elm.price),         0, 0, 'R', 1
      self.ln
      unless elm.comments.blank?
        self.cell @cw[0], 5.0, '', '', 0, 'R', 1
        self.multi_cell @cw[1..4].sum, 5.0, conv(elm.comments), 0, 'L', 1
        self.ln
      end
    end
    self.set_line_width 0.1
    self.line 20.0, self.get_y, 188.0, self.get_y
  end

  def draw_service_items
    self.set_font 'Helvetica', 'B', 11.0
    self.write 5.0, conv('Dienstleistungen')
    self.ln 9.0
    self.set_font 'Helvetica', '', 9.0

    self.set_text_color 0
    self.set_draw_color 16, 16, 50
    self.set_line_width 0.3
    self.set_font 'Helvetica', 'B'
    self.cell @cw[0], 6.0, conv('Anz.'),            'B', 0, 'L', 1
    self.cell @cw[1]+@cw[2], 6.0, conv('Leistung'), 'B', 0, 'C', 1
    self.cell @cw[3], 6.0, conv('Std.-Satz'),       'B', 0, 'R', 1
    self.cell @cw[4], 6.0, conv('Gesamtpreis'),     'B', 0, 'R', 1
    self.set_font 'Helvetica', ''
    self.ln

#     self.set_fill_color 240, 240, 256
    @process.service_items.each do |elm|
      self.cell @cw[0], 6.0, elm.count.to_s + ' x',    0, 0, 'R', 1
      self.cell @cw[1]+@cw[2], 6.0, conv(elm.product.full_name), 0, 0, 'L', 1
      self.cell @cw[3], 6.0, money(elm.unit_price),    0, 0, 'R', 1
      self.cell @cw[4], 6.0, money(elm.price),         0, 0, 'R', 1
      self.ln
      unless elm.comments.blank?
        self.cell @cw[0], 5.0, '', '', 0, 'R', 1
        self.multi_cell @cw[1..4].sum, 5.0, conv(elm.comments), 0, 'L', 1
        self.ln
      end
    end
    self.set_line_width 0.1
    self.line 20.0, self.get_y, 188.0, self.get_y
  end

  def draw_selling_device_items
    self.set_font 'Helvetica', '', 9.0
    self.set_text_color 0
    self.set_draw_color 16, 16, 50
    self.set_line_width 0.3
    self.set_font 'Helvetica', 'B'
    self.cell @cw[0], 6.0, conv('Anz.'),           'B', 0, 'L', 1
    self.cell @cw[1]+@cw[2], 6.0, conv('Artikel'), 'B', 0, 'C', 1
    self.cell @cw[3], 6.0, conv('Einzelpreis'),    'B', 0, 'R', 1
    self.cell @cw[4], 6.0, conv('Gesamtpreis'),    'B', 0, 'R', 1
    self.set_font 'Helvetica', ''
    self.ln

    @process.device_items.each do |elm|
      self.cell @cw[0], 6.0, elm.count.to_s + ' x',    0, 0, 'R', 1
      self.cell @cw[1]+@cw[2], 6.0, conv(elm.product.full_name), 0, 0, 'L', 1
      self.cell @cw[3], 6.0, money(elm.unit_price),    0, 0, 'R', 1
      self.cell @cw[4], 6.0, money(elm.price),         0, 0, 'R', 1
      self.ln
      unless elm.comments.blank?
        self.cell @cw[0], 5.0, '', '', 0, 'R', 1
        self.multi_cell @cw[1..4].sum, 5.0, conv(elm.comments), 0, 'L', 1
        self.ln
      end
    end
    self.set_line_width 0.1
    self.line 20.0, self.get_y, 188.0, self.get_y
  end

  def draw_service_subtotal
    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('Zwischensumme Dienstleistungen:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[4], 6.0, money(@process.service_items.collect(&:price).sum), 'B', 0, 'R', 0
    self.ln
  end

  def draw_device_subtotal
    self.cell @cw[0], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[1], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[2], 6.0, conv('Zwischensumme Artikel:'), '', 0, 'R', 0
    self.cell @cw[3], 6.0, '', 0, 0, 'L', 0
    self.cell @cw[4], 6.0, money(@process.device_items.collect(&:price).sum), 'B', 0, 'R', 0
    self.ln
  end
end
