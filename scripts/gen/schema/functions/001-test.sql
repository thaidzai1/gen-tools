CREATE FUNCTION public.update_rid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.rid = nextval(TG_ARGV[0]);
    RETURN NEW;
END
$$;