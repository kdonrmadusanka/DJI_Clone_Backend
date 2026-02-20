-- CreateEnum
CREATE TYPE "ProductStatus" AS ENUM ('draft', 'published', 'archived', 'discontinued');

-- CreateEnum
CREATE TYPE "VariantStatus" AS ENUM ('active', 'out_of_stock', 'pre_order');

-- CreateEnum
CREATE TYPE "MediaType" AS ENUM ('image', 'video', 'thumbnail', 'cover', 'gallery', 'comparison');

-- CreateTable
CREATE TABLE "categories" (
    "category_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "deleted_at" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "parent_id" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    "is_visible" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("category_id")
);

-- CreateTable
CREATE TABLE "product_series" (
    "series_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "image_url" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    "deleted_at" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "category_id" TEXT NOT NULL,

    CONSTRAINT "product_series_pkey" PRIMARY KEY ("series_id")
);

-- CreateTable
CREATE TABLE "products" (
    "product_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "short_description" TEXT NOT NULL,
    "full_description" TEXT,
    "status" "ProductStatus" NOT NULL DEFAULT 'draft',
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "is_new" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "release_date" TIMESTAMP(3),
    "seo_title" TEXT,
    "seo_description" TEXT,
    "seo_keywords" TEXT[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "category_id" TEXT NOT NULL,
    "series_id" TEXT,

    CONSTRAINT "products_pkey" PRIMARY KEY ("product_id")
);

-- CreateTable
CREATE TABLE "product_variants" (
    "variant_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "price" DECIMAL(65,30) NOT NULL,
    "compare_at_price" DECIMAL(65,30),
    "stock" INTEGER NOT NULL DEFAULT 0,
    "weight" DECIMAL(65,30),
    "dimensions" TEXT,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "status" "VariantStatus" NOT NULL DEFAULT 'active',
    "order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "product_id" TEXT NOT NULL,

    CONSTRAINT "product_variants_pkey" PRIMARY KEY ("variant_id")
);

-- CreateTable
CREATE TABLE "product_attributes" (
    "attribute_id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "group" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "product_id" TEXT,
    "variant_id" TEXT,

    CONSTRAINT "product_attributes_pkey" PRIMARY KEY ("attribute_id")
);

-- CreateTable
CREATE TABLE "product_media" (
    "media_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "type" "MediaType" NOT NULL DEFAULT 'gallery',
    "alt_text" TEXT NOT NULL,
    "caption" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "product_id" TEXT,
    "variant_id" TEXT,

    CONSTRAINT "product_media_pkey" PRIMARY KEY ("media_id")
);

-- CreateTable
CREATE TABLE "product_region_pricing" (
    "region_pricing_id" TEXT NOT NULL,
    "region_code" TEXT NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "price" DECIMAL(65,30) NOT NULL,
    "compare_at_price" DECIMAL(65,30),
    "tax_included" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "variant_id" TEXT NOT NULL,

    CONSTRAINT "product_region_pricing_pkey" PRIMARY KEY ("region_pricing_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "categories_slug_key" ON "categories"("slug");

-- CreateIndex
CREATE INDEX "idx_category_parent" ON "categories"("parent_id");

-- CreateIndex
CREATE INDEX "idx_category_order" ON "categories"("order");

-- CreateIndex
CREATE INDEX "idx_category_slug" ON "categories"("slug");

-- CreateIndex
CREATE INDEX "idx_category_visibility" ON "categories"("is_visible");

-- CreateIndex
CREATE UNIQUE INDEX "product_series_slug_key" ON "product_series"("slug");

-- CreateIndex
CREATE INDEX "idx_series_category" ON "product_series"("category_id");

-- CreateIndex
CREATE INDEX "idx_series_slug" ON "product_series"("slug");

-- CreateIndex
CREATE INDEX "idx_series_order" ON "product_series"("order");

-- CreateIndex
CREATE INDEX "idx_series_active" ON "product_series"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "products_slug_key" ON "products"("slug");

-- CreateIndex
CREATE INDEX "idx_product_category" ON "products"("category_id");

-- CreateIndex
CREATE INDEX "idx_product_series" ON "products"("series_id");

-- CreateIndex
CREATE INDEX "idx_product_slug" ON "products"("slug");

-- CreateIndex
CREATE INDEX "idx_product_status" ON "products"("status");

-- CreateIndex
CREATE INDEX "idx_product_featured" ON "products"("is_featured");

-- CreateIndex
CREATE INDEX "idx_product_created" ON "products"("created_at");

-- CreateIndex
CREATE INDEX "idx_product_release" ON "products"("release_date");

-- CreateIndex
CREATE INDEX "idx_product_display" ON "products"("status", "is_featured", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "product_variants_sku_key" ON "product_variants"("sku");

-- CreateIndex
CREATE INDEX "idx_variant_product" ON "product_variants"("product_id");

-- CreateIndex
CREATE INDEX "idx_variant_sku" ON "product_variants"("sku");

-- CreateIndex
CREATE INDEX "idx_variant_status" ON "product_variants"("status");

-- CreateIndex
CREATE INDEX "idx_variant_order" ON "product_variants"("order");

-- CreateIndex
CREATE INDEX "idx_variant_created" ON "product_variants"("created_at");

-- CreateIndex
CREATE INDEX "idx_variant_availability" ON "product_variants"("status", "stock");

-- CreateIndex
CREATE INDEX "idx_variant_price" ON "product_variants"("price");

-- CreateIndex
CREATE INDEX "idx_attribute_product" ON "product_attributes"("product_id");

-- CreateIndex
CREATE INDEX "idx_attribute_variant" ON "product_attributes"("variant_id");

-- CreateIndex
CREATE INDEX "idx_attribute_group" ON "product_attributes"("group");

-- CreateIndex
CREATE INDEX "idx_attribute_order" ON "product_attributes"("order");

-- CreateIndex
CREATE INDEX "idx_attribute_key_value" ON "product_attributes"("key", "value");

-- CreateIndex
CREATE INDEX "idx_attribute_product_key" ON "product_attributes"("product_id", "key");

-- CreateIndex
CREATE INDEX "idx_media_product" ON "product_media"("product_id");

-- CreateIndex
CREATE INDEX "idx_media_variant" ON "product_media"("variant_id");

-- CreateIndex
CREATE INDEX "idx_media_type" ON "product_media"("type");

-- CreateIndex
CREATE INDEX "idx_media_order" ON "product_media"("order");

-- CreateIndex
CREATE INDEX "idx_media_primary" ON "product_media"("is_primary");

-- CreateIndex
CREATE INDEX "idx_media_product_primary" ON "product_media"("product_id", "is_primary");

-- CreateIndex
CREATE INDEX "idx_media_product_display" ON "product_media"("product_id", "type", "order");

-- CreateIndex
CREATE INDEX "idx_region_pricing_variant" ON "product_region_pricing"("variant_id");

-- CreateIndex
CREATE INDEX "idx_region_pricing_region" ON "product_region_pricing"("region_code");

-- CreateIndex
CREATE INDEX "idx_region_pricing_currency" ON "product_region_pricing"("currency");

-- CreateIndex
CREATE INDEX "idx_region_pricing_region_currency" ON "product_region_pricing"("region_code", "currency");

-- CreateIndex
CREATE UNIQUE INDEX "product_region_pricing_variant_id_region_code_key" ON "product_region_pricing"("variant_id", "region_code");

-- AddForeignKey
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "categories"("category_id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "product_series" ADD CONSTRAINT "product_series_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("category_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "products" ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("category_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "products" ADD CONSTRAINT "products_series_id_fkey" FOREIGN KEY ("series_id") REFERENCES "product_series"("series_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("product_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attributes" ADD CONSTRAINT "product_attributes_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("product_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_attributes" ADD CONSTRAINT "product_attributes_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("variant_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_media" ADD CONSTRAINT "product_media_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("product_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_media" ADD CONSTRAINT "product_media_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("variant_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_region_pricing" ADD CONSTRAINT "product_region_pricing_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("variant_id") ON DELETE RESTRICT ON UPDATE CASCADE;
