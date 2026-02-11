-- Enable RLS on tables
ALTER TABLE "public"."vehicles" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."service_history" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."delivery_orders" ENABLE ROW LEVEL SECURITY;

-- 1. Policies for 'vehicles'
-- Owners can see their own vehicles
CREATE POLICY "Users can view own vehicles" ON "public"."vehicles"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (auth.uid() = owner_id);

-- Owners can insert their own vehicles
CREATE POLICY "Users can insert own vehicles" ON "public"."vehicles"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- Owners can update their own vehicles
CREATE POLICY "Users can update own vehicles" ON "public"."vehicles"
AS PERMISSIVE FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id);

-- Owners can delete their own vehicles
CREATE POLICY "Users can delete own vehicles" ON "public"."vehicles"
AS PERMISSIVE FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);

-- 2. Policies for 'service_history'
-- Providers can view service history they performed
CREATE POLICY "Providers can view assigned service history" ON "public"."service_history"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (auth.uid() = provider_id);

-- Vehicle owners can view service history for their vehicles (requires join/subquery)
CREATE POLICY "Owners can view service history for their vehicles" ON "public"."service_history"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.vehicles 
    WHERE vehicles.id = service_history.vehicle_id 
    AND vehicles.owner_id = auth.uid()
  )
);

-- Providers can insert service records
CREATE POLICY "Providers can insert service records" ON "public"."service_history"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = provider_id);


-- 3. Policies for 'orders'
-- Users can view their own orders
CREATE POLICY "Users can view own orders" ON "public"."orders"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can create orders
CREATE POLICY "Users can create orders" ON "public"."orders"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);


-- 4. Policies for 'delivery_orders'
-- Customers/Sellers/Drivers involved can view the order
CREATE POLICY "Parties involved can view delivery orders" ON "public"."delivery_orders"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (
  auth.uid() = customer_id OR 
  auth.uid() = seller_id OR 
  auth.uid() = driver_id
);

-- Drivers can see pending orders to potentially accept them
CREATE POLICY "Drivers can view pending delivery orders" ON "public"."delivery_orders"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (status = 'pending');

-- Drivers can update orders they are assigned to
CREATE POLICY "Drivers can update assigned orders" ON "public"."delivery_orders"
AS PERMISSIVE FOR UPDATE
TO authenticated
USING (auth.uid() = driver_id);


-- 5. Admin Access (Example)
-- If you have an `is_admin` claim or a `profiles` table role check:
/*
CREATE POLICY "Admins have full access" ON "public"."vehicles"
AS PERMISSIVE FOR ALL
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'super_admin')
);
*/
