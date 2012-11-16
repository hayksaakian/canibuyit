class ProductsController < ApplicationController
  # GET /products
  # GET /products.json
  def index
    @products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @products }
    end
  end

  def subscribe
    @product = Product.find(params[:product_id])
    @address = params[:email_address]
    respond_to do |format|
      if @address =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
        if not @product.addresses.include?(@address)
          @product.addresses.push(@address)
          @product.save
          notice = 'you\'ll get an email once it\'s available; to remove yourself from the list, submit your email again.'
        else
          notice = 'your address was already on the list, by submitting it again you removed it; to add it back submit it again.'
        end
        format.html { redirect_to @product, notice: notice }
      else
        format.html { redirect_to @product, notice: 'the sanity check does not think you provided an email address, check it and try again:' }
      end
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])
    @product.check_available
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @product }
    end
  end

  def nexus4
    @product = Product.find('nexus-4')
    @product.check_available
    respond_to do |format|
      format.html { redirect_to @product }
      # format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        # format.json { head :ok }
      else
        format.html { render action: "edit" }
        # format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      # format.json { head :ok }
    end
  end
end
