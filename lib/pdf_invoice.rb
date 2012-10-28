class PdfInvoice < PdfLetter

  def initialize(invoice)
    @invoice = invoice
    @process = invoice.process
    super(@process.sender, @process.client, conv('R E C H N U N G'), '')
    @top_header_fields[1] = conv('Rechnungs-Nr.')
    @top_header_fields[2] = conv('VG-Nr.')
    @top_header_fields[3] = conv('Bearbeiter')
    @top_header_fields[4] = conv("Witten, #{@invoice.date}")
    @bottom_header_fields[1] = @invoice.invoice_no.to_s
    @bottom_header_fields[2] = @process.process_no
    @bottom_header_fields[3] = conv(@invoice.user.full_name)
  end

  def main_content
    w = [10.0, 100.0, 20.0, 14.0, 24.0] # cell widths

    self.set_font 'Helvetica', '', 10.0
    if @process.respond_to? :begin
      self.write 5.0, conv("Für die von Ihnen im Zeitraum vom #{@process.begin.to_date} bis #{@process.end.to_date} in Anspruch genommenen Leistungen erlauben wir uns, folgende Rechnung zu stellen:")
    else
      self.write 5.0, conv('Für die von Ihnen in Anspruch genommenen Leistungen erlauben wir uns, folgende Rechnung zu stellen:')
    end
    self.ln 9.0
    if self.selling? and @process.device_items.any?
      ###### DEVICES #############################################################################
      self.set_font 'Helvetica', 'B', 11.0
      self.write 5.0, conv('Artikel')
      self.ln 9.0
      self.set_font 'Helvetica', '', 9.0
      self.set_text_color 0
      self.set_draw_color 16, 16, 50
      self.set_line_width 0.3
      self.set_font 'Helvetica', 'B'
      self.cell w[0], 6.0, conv('Anz.'),        'B', 0, 'L', 1
      self.cell w[1], 6.0, conv('Artikel'),     'B', 0, 'C', 1
      self.cell w[2], 6.0, conv('Einzelpreis'), 'B', 0, 'R', 1
      self.cell w[3], 6.0, '',                  'B', 0, 'R', 1
      self.cell w[4], 6.0, conv('Gesamtpreis'), 'B', 0, 'R', 1
      self.set_font 'Helvetica', ''
      self.ln

      @process.device_items.each do |elm|
        self.cell w[0], 6.0, elm.count.to_s + ' x',                  0, 0, 'R', 1
        self.cell w[1], 6.0, conv(elm.product.full_name),            0, 0, 'L', 1
        self.cell w[2], 6.0, money(elm.unit_price),    0, 0, 'R', 1
        if @invoice.process.respond_to? :billed_duration
          self.cell w[3], 6.0, sprintf('%.2f d', elm.billed_duration), 0, 0, 'R', 1
        else
          self.cell w[3], 6.0, '', 0, 0, 'R', 1
        end
        self.cell w[4], 6.0, money(elm.price),         0, 0, 'R', 1
        self.ln
      end
      self.set_line_width 0.1
      self.line 20.0, self.get_y, 188.0, self.get_y
    end

    if self.rental? and @process.device_items.any?
      ###### DEVICES #############################################################################
      self.set_font 'Helvetica', 'B', 11.0
      self.write 5.0, conv('Artikel')
      self.ln 9.0
      self.set_font 'Helvetica', '', 9.0
      self.set_text_color 0
      self.set_draw_color 16, 16, 50
      self.set_line_width 0.3
      self.set_font 'Helvetica', 'B'
      self.cell w[0], 6.0, conv('Anz.'),        'B', 0, 'L', 1
      self.cell w[1], 6.0, conv('Artikel'),       'B', 0, 'C', 1
      self.cell w[2], 6.0, conv('Tagespreis'),  'B', 0, 'R', 1
      if @invoice.process.respond_to? :billed_duration
        self.cell w[3], 6.0, conv('Dauer'),       'B', 0, 'R', 1
      else
        self.cell w[3], 6.0, '',       'B', 0, 'R', 1
      end
      self.cell w[4], 6.0, conv('Gesamtpreis'), 'B', 0, 'R', 1
      self.set_font 'Helvetica', ''
      self.ln

      @process.device_items.each do |elm|
        self.cell w[0], 6.0, elm.count.to_s + ' x',                  0, 0, 'R', 1
        self.cell w[1], 6.0, conv(elm.product.full_name),            0, 0, 'L', 1
        self.cell w[2], 6.0, money(elm.unit_price),    0, 0, 'R', 1
        if @invoice.process.respond_to? :billed_duration
          self.cell w[3], 6.0, sprintf('%.2f d', elm.billed_duration), 0, 0, 'R', 1
        else
          self.cell w[3], 6.0, '', 0, 0, 'R', 1
        end
        self.cell w[4], 6.0, money(elm.price),         0, 0, 'R', 1
        self.ln
      end
      self.set_line_width 0.1
      self.line 20.0, self.get_y, 188.0, self.get_y
    end

    if @process.service_items.any?
      if @process.device_items.any?
        self.cell w[0], 6.0, '', 0, 0, 'L', 0
        self.cell w[1], 6.0, '', 0, 0, 'L', 0
        self.cell w[2], 6.0, conv('Zwischensumme Artikel:'), '', 0, 'R', 0
        self.cell w[3], 6.0, '', 0, 0, 'L', 0
        self.cell w[4], 6.0, money(@process.device_items.collect(&:price).sum), 'B', 0, 'R', 0
        self.ln
      end
      ###### SERVICES ############################################################################
      self.set_font 'Helvetica', 'B', 11.0
      self.write 5.0, conv('Dienstleistungen')
      self.ln 9.0
      self.set_font 'Helvetica', '', 9.0

      self.set_text_color 0
      self.set_draw_color 16, 16, 50
      self.set_line_width 0.3
      self.set_font 'Helvetica', 'B'
      self.cell w[0], 6.0, conv('Anz.'),        'B', 0, 'L', 1
      self.cell w[1], 6.0, conv('Leistung'),    'B', 0, 'C', 1
      self.cell w[2], 6.0, conv('Std.-Satz'),   'B', 0, 'R', 1
      self.cell w[3], 6.0, conv('Dauer'),       'B', 0, 'C', 1
      self.cell w[4], 6.0, conv('Gesamtpreis'), 'B', 0, 'R', 1
      self.set_font 'Helvetica', ''
      self.ln

  #     self.set_fill_color 240, 240, 256
      @process.service_items.each do |elm|
        self.cell w[0], 6.0, elm.count.to_s + ' x',       0, 0, 'R', 1
        self.cell w[1], 6.0, conv(elm.product.full_name), 0, 0, 'L', 1
        self.cell w[2], 6.0, money(elm.unit_price),       0, 0, 'R', 1
        self.cell w[3], 6.0, conv("#{elm.duration} #{elm.product.unit}"), 0, 0, 'R', 1
        self.cell w[4], 6.0, money(elm.price),            0, 0, 'R', 1
        self.ln
#         if APP_SETTINGS[:show_article_comments_in_invoice] and not elm.comments.blank?
#           self.cell w[0], 5.0, '', '', 0, 'R', 1
#           self.cell w[1..4].sum, 5.0, conv(elm.comments[0...100]), '', 0, 'L', 1
#           self.ln
#         end
      end
      self.set_line_width 0.1
      self.line 20.0, self.get_y, 188.0, self.get_y
      self.cell w[0], 6.0, '', 0, 0, 'L', 0
      self.cell w[1], 6.0, '', 0, 0, 'L', 0
      self.cell w[2], 6.0, conv('Zwischensumme Dienstleitungen:'), '', 0, 'R', 0
      self.cell w[3], 6.0, '', 0, 0, 'L', 0
      self.cell w[4], 6.0, money(@process.service_items.collect(&:price).sum), 'B', 0, 'R', 0
      self.ln
    end


    self.cell w[0], 6.0, '', 0, 0, 'L', 0
    self.cell w[1], 6.0, '', 0, 0, 'L', 0
    self.cell w[2], 6.0, conv('Gesamtsumme:'), '', 0, 'R', 0
    self.cell w[3], 6.0, '', 0, 0, 'L', 0
    self.cell w[4], 6.0, money(@process.sum), 'B', 0, 'R', 0
    self.ln

    unless @process.client_discount == 0.0
      self.cell w[0], 6.0, '', 0, 0, 'L', 0
      self.cell w[1], 6.0, '', 0, 0, 'L', 0
      self.cell w[2], 6.0, conv('Kundenrabatt:'), '', 0, 'R', 0
      self.cell w[3], 6.0, conv(sprintf('%.2f%%', @process.client_discount_percent)), 0, 0, 'R', 0
      self.cell w[4], 6.0, money(-@process.client_discount), '', 0, 'R', 0
      self.ln
    end

    unless @process.discount == 0.0
      self.cell w[0], 6.0, '', 0, 0, 'L', 0
      self.cell w[1], 6.0, '', 0, 0, 'L', 0
      self.cell w[2], 6.0, conv('Auftragsrabatt:'), '', 0, 'R', 0
      self.cell w[3], 6.0, '', 0, 0, 'R', 0
      self.cell w[4], 6.0, money(-@process.discount), '', 0, 'R', 0
      self.ln
    end

    self.set_line_width 0.6
    self.set_font 'Helvetica', 'B'
    self.cell w[0], 6.0, '', 0, 0, 'L', 0
    self.cell w[1], 6.0, '', 0, 0, 'L', 0
    self.cell w[2], 6.0, conv('Total Netto:'), '', 0, 'R', 0
    self.cell w[3], 6.0, '', 0, 0, 'R', 0
    self.cell w[4], 6.0, money(@process.net_total_price), 'B', 0, 'R', 0
    self.ln

    self.set_font 'Helvetica', ''
    self.cell w[0], 6.0, '', 0, 0, 'L', 0
    self.cell w[1], 6.0, '', 0, 0, 'L', 0
    self.cell w[2], 6.0, conv('MwSt:'), '', 0, 'R', 0
    self.cell w[3], 6.0, conv('19.0%'), 0, 0, 'R', 0
    self.cell w[4], 6.0, money(@process.vat), '', 0, 'R', 0
    self.ln

    self.set_font 'Helvetica', 'B'
    self.cell w[0], 6.0, '', 0, 0, 'L', 0
    self.cell w[1], 6.0, '', 0, 0, 'L', 0
    self.cell w[2], 6.0, conv('Total Brutto:'), '', 0, 'R', 0
    self.cell w[3], 6.0, '', 0, 0, 'R', 0
    self.cell w[4], 6.0, money(@process.gross_total_price), 'B', 0, 'R', 0

    self.ln 12.0
    self.set_font 'Helvetica', '', 10.0
    self.write 4.5, conv(@invoice.remarks)
  end

  def selling?
    @process.is_a? Selling
  end

  def rental?
    @process.is_a? Rental
  end
end
