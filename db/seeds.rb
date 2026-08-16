restaurant = Restaurant.find_or_create_by!(subdomain: "demo") do |r|
  r.name = "La Esquina Demo"
  r.timezone = "America/Bogota"
  r.currency = "COP"
end

ActsAsTenant.with_tenant(restaurant) do
  owner = User.find_or_create_by!(email: "demo@menucito.app") do |u|
    u.name = "Ana Dueña"
    u.password = "password123"
    u.role = :owner
  end

  cashier = User.find_or_create_by!(email: "caja@menucito.app") do |u|
    u.name = "Carlos Cajero"
    u.password = "password123"
    u.role = :cashier
  end

  waiter = User.find_or_create_by!(email: "mesero@menucito.app") do |u|
    u.name = "Wilson Mesero"
    u.password = "password123"
    u.role = :waiter
  end

  kitchen = User.find_or_create_by!(email: "cocina@menucito.app") do |u|
    u.name = "Karla Cocina"
    u.password = "password123"
    u.role = :kitchen
  end

  categories = {
    "Entradas" => [ [ "Patacones con hogao", 12000 ], [ "Empanadas x3", 9000 ] ],
    "Platos fuertes" => [ [ "Bandeja paisa", 32000 ], [ "Sancocho de gallina", 28000 ], [ "Pechuga a la plancha", 25000 ] ],
    "Bebidas" => [ [ "Limonada de coco", 8000 ], [ "Jugo de mora", 7000 ], [ "Gaseosa", 5000 ], [ "Agua", 3000 ], [ "Cerveza", 9000 ], [ "Café", 3500 ] ],
    "Postres" => [ [ "Flan de caramelo", 8000 ], [ "Tres leches", 9000 ] ],
  }

  categories.each_with_index do |(cat_name, items), i|
    category = MenuCategory.find_or_create_by!(name: cat_name) { |c| c.position = i; c.active = true }
    items.each_with_index do |(name, price), j|
      MenuItem.find_or_create_by!(name: name, menu_category: category) do |m|
        m.price = price
        m.position = j
        m.available = true
      end
    end
  end

  (1..8).each do |n|
    DiningTable.find_or_create_by!(code: n.to_s) { |t| t.capacity = 4; t.position = n }
  end

  Discount.find_or_create_by!(name: "Empleados") do |d|
    d.kind = :percentage
    d.value = 10
    d.active = true
  end

  Discount.find_or_create_by!(name: "Cliente frecuente") do |d|
    d.kind = :fixed_amount
    d.value = 5000
    d.active = true
  end

  puts "Demo restaurant ready -> subdomain: demo"
  puts "Owner: demo@menucito.app / password123"
  puts "Cashier: caja@menucito.app / password123"
  puts "Waiter: mesero@menucito.app / password123"
  puts "Kitchen: cocina@menucito.app / password123"
end
