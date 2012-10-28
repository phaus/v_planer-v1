require 'iconv'
require 'fpdf'

class PdfLetter < FPDF

  @@border_left   = 20.0
  @@border_top    = 25.0
  @@border_bottom = 30.0
  @@converter     = Iconv.new('iso-8859-15', 'utf-8')

  def initialize(sender, recipient, subject, content='', options={})
    super()
    @subject, @sender, @recipient, @content = subject, sender, recipient, content

    @top_header_fields    ||= [conv('Ihre Kundennummer'), conv('VG-Nr.'), '', '', conv("Witten, #{Date.today}")]
    @bottom_header_fields ||= [@recipient.client_no||'', '', '', '', '']

    self.add_page
    self.set_margins @@border_left, @@border_top
    self.set_auto_page_break 0
  end

  def header
    self.image Rails.root.join('public', 'images', 'header.jpg'), -40, 0, 240

    self.set_fill_color 255
    self.set_text_color 0
    self.set_draw_color 0
    self.set_line_width 0.1
    self.set_font  'Helvetica', '', 8
    self.set_y 57.0
    self.multi_cell 93.0, 3.2, @sender.company.sender_address_window||'', 'B', 'L'

    self.set_font  'Helvetica', '', 10.0
    self.set_y 65.0
    self.multi_cell 90.0, 4.5, conv("#{@recipient.company_name} \n" +
                                    "#{@recipient.full_name} \n" +
                                    "#{(@recipient.address||@recipient.build_address).street} \n" +
                                    "#{@recipient.address.postalcode} #{@recipient.address.locality} \n")

    self.set_font  'Helvetica', '', 10.0
    self.set_y 65.0
    self.set_x 120.0
    self.multi_cell 90.0, 4.5, conv(@sender.company.sender_address_block)
  end

  def footer
    self.set_x_y @@border_left + 2, -28.0
    self.set_font  'Helvetica', 'b', 9.0
    self.set_text_color 120.0
    self.cell 55.0, 3.5, conv(@sender.company.name), 0, 1, 'L', 0
    self.set_font  'Helvetica', '', 8.0
    self.set_x @@border_left + 2
    self.cell 55.0, 3.5, conv(@sender.company.street), 0, 1, 'L', 0
    self.set_x @@border_left + 2
    self.cell 55.0, 3.5, conv("#{@sender.company.postalcode} #{@sender.company.locality}"), 0, 1, 'L', 0
    self.set_x @@border_left + 2
    self.cell 55.0, 3.5, conv("Tel. #{@sender.company.phone}"), 0, 1, 'L', 0 unless @sender.company.phone.blank?
    self.set_x @@border_left + 2
    self.cell 55.0, 3.5, conv("Fax. #{@sender.company.fax}"), 0, 1, 'L', 0 unless @sender.company.fax.blank?
    self.set_x @@border_left + 2
    self.cell 55.0, 3.5, conv("Mob. #{@sender.company.mobile}"), 0, 1, 'L', 0 unless @sender.company.mobile.blank?
    self.set_font  'Helvetica', 'b', 9.0
    self.set_x_y 80.0, -28.0
    self.cell 55.0, 4.0, 'Bankverbindung', 0, 1, 'L', 0
    self.set_font  'Helvetica', '', 8.0
    self.set_x 80.0
    self.multi_cell 55.0, 3.5, "#{conv @sender.bank_name||' '}\n"+
        "KTO:  #{conv @sender.bank_account.number.to_s}\n"+
        "BLZ:  #{conv @sender.bank_account.blz.to_s}\n"+
        "IBAN: #{conv @sender.bank_account.iban.to_s}\n"+
        "BIC:  #{conv @sender.bank_account.bic.to_s}", 0, 'L', 0
    self.set_font  'Helvetica', 'b', 9.0
    self.set_x_y 135.0, -28.0
    self.cell 55.0, 4.0, 'Internet', 0, 1, 'L', 0
    self.set_font  'Helvetica', '', 8.0
    self.set_x 135.0
    self.cell 55.0, 3.5, conv(@sender.homepage), 0, 1, 'L', 0
    self.set_x 135.0
    self.cell 55.0, 4.0, conv(@sender.email), 0, 1, 'L', 0
    self.set_x 135.0
    self.cell 55.0, 4.0, conv("Steuernr.: #{@sender.tax_id}"), 0, 1, 'L', 0 unless @sender.tax_id.blank?
    self.set_x 135.0
    self.cell 55.0, 4.0, conv("Ust.-ID: #{@sender.vat_id}"), 0, 1, 'L', 0 unless @sender.vat_id.blank?

    self.set_draw_color 111, 145, 178
    self.set_line_width 1.0
    self.line @@border_left, 270.0, @@border_left, 293.0
    self.line 77.0, 270.0, 77.0, 293.0
    self.line 133.0, 270.0, 133.0, 293.0

  end
  alias Footer footer

  def letter_head
    self.set_x_y @@border_left, 105.0
    self.set_font  'Helvetica', '', 8.0
    for top in @top_header_fields
      self.cell 35.5, 5.0, top, 0, 0, 'L', 0
    end

    self.ln 5.0

    self.set_font  'Helvetica', 'I', 8.0
    for bottom in @bottom_header_fields
      self.cell 35.5, 5.0, bottom, 0, 0, 'L', 0
    end

    self.ln 10.0

    self.set_font  'Helvetica', '', 12.0
    self.cell 40.0, 8.0, conv(@subject), 0, 2, 'L', 0

    self.set_font  'Helvetica', '', 11
    self.set_x_y @@border_left, 125.0
    self.ln 6.0
    self.set_auto_page_break 1, 40
  end

  def main_content
    self.ln 10.0
    self.set_font 'Helvetica', '', 10.0
    self.write 6.0, conv(@content)
  end

  def to_s
    self.header
#     self.footer
    self.letter_head
    self.main_content
    self.set_compression true
    self.output
  end

  protected

  def money(val)
    sprintf('%.2f EUR', val).sub('.', ',')
  end

  def conv(input_text)
    @@converter.iconv(input_text || '')
  rescue Iconv::IllegalSequence
    input_text
  end
end
