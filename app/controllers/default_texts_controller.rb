class DefaultTextsController < ApplicationController
  # GET /default_texts
  # GET /default_texts.xml
  def index
    @default_texts = current_user.company_section.default_texts.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @default_texts }
    end
  end

  # GET /default_texts/1
  # GET /default_texts/1.xml
  def show
    @default_text = DefaultText.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @default_text }
    end
  end

  # GET /default_texts/new
  # GET /default_texts/new.xml
  def new
    @default_text = DefaultText.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @default_text }
    end
  end

  # GET /default_texts/1/edit
  def edit
    @default_text = DefaultText.find(params[:id])
  end

  # POST /default_texts
  # POST /default_texts.xml
  def create
    @default_text = DefaultText.new(params[:default_text])
    @default_text.company_section = current_user.company_section

    respond_to do |format|
      if @default_text.save
        flash[:notice] = 'DefaultText was successfully created.'
        format.html { redirect_to(@default_text) }
        format.xml  { render :xml => @default_text, :status => :created, :location => @default_text }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @default_text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /default_texts/1
  # PUT /default_texts/1.xml
  def update
    @default_text = DefaultText.find(params[:id])

    respond_to do |format|
      if @default_text.update_attributes(params[:default_text])
        flash[:notice] = 'DefaultText was successfully updated.'
        format.html { redirect_to(@default_text) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @default_text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /default_texts/1
  # DELETE /default_texts/1.xml
  def destroy
    @default_text = DefaultText.find(params[:id])
    @default_text.destroy

    respond_to do |format|
      format.html { redirect_to(default_texts_url) }
      format.xml  { head :ok }
    end
  end
end
