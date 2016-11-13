CREATE OR REPLACE FUNCTION im.get_image(image_id int) RETURNS json AS 
$BODY$
DECLARE
  found_image im.image;
  image_tags json;
  image_comments json;
BEGIN
  -- Load the image data:
  SELECT * INTO found_image 
  FROM im.image i 
  WHERE i.imageid = image_id;  

  -- Get assigned tags:
  SELECT CASE WHEN COUNT(x) = 0 THEN '[]' ELSE json_agg(x) END INTO image_tags 
  FROM (SELECT t.* 
        FROM im.image i
        INNER JOIN im.image_tag it ON i.imageid = it.imageid
        INNER JOIN im.tag t ON it.tagid = t.tagid
        WHERE i.imageid = image_id) x;

  -- Get assigned comments:
  SELECT CASE WHEN COUNT(y) = 0 THEN '[]' ELSE json_agg(y) END INTO image_comments 
  FROM (SELECT * 
        FROM im.comment c 
        WHERE c.imageid = image_id) y;

  -- Build the JSON Response:
  RETURN (SELECT json_build_object(
    'imageid', found_image.imageid,
    'hash', found_image.hash,
    'description', found_image.description,
    'created_on', found_image.createdon, 
    'comments', image_comments,
    'tags', image_tags));

END
$BODY$
LANGUAGE 'plpgsql';