class MedicineItem {
  final String name;
  final String imageUrl;
  final double price; // in Rs.
  final double rating; // out of 5 stars

  MedicineItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });

  @override
  String toString() {
    return 'MedicineItem{name: $name, imageUrl: $imageUrl, price: Rs. $price, rating: $rating}';
  }
}

List<MedicineItem> medicines = [
  MedicineItem(
    name: 'Arinac',
    imageUrl:
        'https://th.bing.com/th/id/OIP.N6QhItjra2DFcBNtk3tiMgHaEU?w=289&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 120.50,
    rating: 4.2,
  ),
  MedicineItem(
    name: 'Rotec',
    imageUrl:
        'https://th.bing.com/th/id/OIP.TRb9F_IOKCO6pIuOx_VkNAHaEU?w=255&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 85.75,
    rating: 3.9,
  ),
  MedicineItem(
    name: 'Nospa',
    imageUrl:
        'https://th.bing.com/th/id/OIP.QYGp0m-o5bnw7Kw4TDW56QHaEU?w=283&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 65.00,
    rating: 4.5,
  ),
  MedicineItem(
    name: 'Rigix',
    imageUrl:
        'https://th.bing.com/th/id/OIP.RwXb9icQW4zpBZh_l_X8tAHaEK?w=305&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 95.25,
    rating: 4.1,
  ),
  MedicineItem(
    name: 'Subex',
    imageUrl:
        'https://th.bing.com/th/id/OIP.ZjYH7o-vfNujNY6yJ6ydCgHaEU?w=317&h=184&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 150.00,
    rating: 4.0,
  ),
  MedicineItem(
    name: 'Losartan',
    imageUrl:
        'https://th.bing.com/th/id/OIP.RoXTgANLxXZyTrCqOHdH4QHaEK?w=324&h=182&c=7&r=0&o=7&pid=1.7&rm=3',
    price: 180.50,
    rating: 4.3,
  ),
];

//SIMILARLY FOR DOCTORS:

class DoctorProfile {
  final String name;
  final String imageUrl;
  final String specialization;
  final int rating; // out of 5 stars (integer)
  final double consultationFee; // in Rs.

  DoctorProfile({
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.rating,
    required this.consultationFee,
  });
}

List<DoctorProfile> doctors = [
  DoctorProfile(
    name: 'Dr. Harry Potter',
    imageUrl:
        'https://th.bing.com/th/id/OIP.TYzWK2HqKaqczU98GKeshQHaHZ?rs=1&pid=ImgDetMain',
    specialization: 'Wizarding Medicine',
    rating: 5,
    consultationFee: 12500.00,
  ),
  DoctorProfile(
    name: 'Dr. Sara Khan',
    imageUrl:
        'https://img.freepik.com/premium-photo/young-pakistani-doctor-girl-celebrating-pakistan-14th-august-day_993198-167.jpg',
    specialization: 'General Physician',
    rating: 4,
    consultationFee: 1500.00,
  ),
  DoctorProfile(
    name: 'Dr. Sania Mirza',
    imageUrl:
        'https://bmidoctors.com/wp-content/uploads/2024/03/weight-loss-doctor-1-scaled.jpg',
    specialization: 'Nutrition & Weight Loss',
    rating: 5,
    consultationFee: 2000.00,
  ),
];
