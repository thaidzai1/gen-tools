CREATE FUNCTION public.example() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  merchantPlanID INT8;
  rec RECORD;
BEGIN
    /*-- Logic here --*/
END
$$;