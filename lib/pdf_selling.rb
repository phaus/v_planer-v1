class PdfSelling< PdfLetter

  def initialize(rental)
    @selling = rental
    super(@selling.sender, @selling.client, conv('L I E F E R S C H E I N'), '')
    @top_header_fields[1]    = conv('VG-Nr.')
    @bottom_header_fields[1] = @selling.process_no
    @top_header_fields[2]    = conv('Bearbeiter')
    @bottom_header_fields[2] = @selling.user.full_name
  end

  def main_content
    w = [10.0, 152.0, 6.0] # cell widths

#     self.set_font 'Helvetica', '', 10.0
    self.ln 10.0
#     self.set_font 'Helvetica', '', 9.0

#     self.set_fill_color 198, 226, 247
    self.set_text_color 0
    self.set_draw_color 16, 16, 50
    self.set_line_width 0.3
    self.set_font 'Helvetica', 'B'
    self.cell w[0], 6.0, conv('Anz.'),        'B', 0, 'L', 1
    self.cell w[1], 6.0, conv('Artikel'),     'B', 0, 'L', 1
#     self.cell w[2], 6.0, conv('gepackt'),  'B', 0, 'R', 1
    self.set_font 'Helvetica', ''
    self.ln

#     self.set_fill_color 240, 240, 256
    @selling.items.each do |elm|
      self.cell w[0], 6.0, elm.count.to_s + ' x',       0, 0, 'R', 1
      self.cell w[1], 6.0, conv(elm.product.full_name), 0, 0, 'L', 1
#       self.cell w[2], 6.0, '',                     'TLRB', 0, 'L', 1
      self.ln
      unless elm.comments.blank?
        self.cell w[0], 5.0, '', '', 0, 'R', 1
        self.cell w[1..2].sum, 5.0, conv(elm.comments[0...100]), '', 0, 'L', 1
        self.ln
      end
    end
    self.set_line_width 0.1
    self.line 20.0, self.get_y, 188.0, self.get_y

    self.ln 12.0
    self.set_font 'Helvetica', '', 10.0
#     self.write 4.5, conv('blah blah.')
#     self.ln 8.0
    self.write 6.0, conv('Datum/Unterschrift Kunde')
  end
end
