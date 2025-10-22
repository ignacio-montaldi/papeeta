INSERT INTO recipes (title, subtitle, user_id)
VALUES (
  'Cinnamon Rolls',
  'Rollos de canela, con azucar negra y cubiertos con crema de vainilla',
  now(),
  '273b5634-f824-4d8c-99e3-5850907111d1'
)
RETURNING id;

