<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kubebytes Travel Agency | Explore the World</title>
    <style>
        /* General Styles */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; color: #333; line-height: 1.6; }

        /* Navigation */
        nav { background: #2c3e50; color: #fff; padding: 1rem 5%; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1000; }
        nav .logo { font-size: 1.5rem; font-weight: bold; color: #3498db; }
        nav ul { display: flex; list-style: none; }
        nav ul li { margin-left: 20px; }
        nav ul li a { color: #fff; text-decoration: none; font-weight: 500; transition: 0.3s; }
        nav ul li a:hover { color: #3498db; }

        /* Hero Section */
        .hero { 
            background: linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.5)), url('https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?ixlib=rb-4.0.3&auto=format&fit=crop&w=1440&q=80');
            background-size: cover; background-position: center; height: 60vh;
            display: flex; flex-direction: column; justify-content: center; align-items: center;
            color: #fff; text-align: center; padding: 0 20px;
        }
        .hero h1 { font-size: 3.5rem; margin-bottom: 1rem; text-shadow: 2px 2px 10px rgba(0,0,0,0.5); }
        .hero p { font-size: 1.2rem; margin-bottom: 2rem; }
        .btn { background: #3498db; color: #fff; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; transition: 0.3s; }
        .btn:hover { background: #2980b9; }

        /* Packages Section */
        .container { max-width: 1200px; margin: 50px auto; padding: 0 20px; }
        .section-title { text-align: center; margin-bottom: 40px; }
        .section-title h2 { font-size: 2.5rem; color: #2c3e50; }
        
        .packages-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }
        .card { background: #fff; border-radius: 10px; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.1); transition: transform 0.3s; }
        .card:hover { transform: translateY(-10px); }
        .card img { width: 100%; height: 200px; object-fit: cover; }
        .card-content { padding: 20px; }
        .card-content h3 { margin-bottom: 10px; color: #2c3e50; }
        .card-content p { color: #666; margin-bottom: 15px; font-size: 0.95rem; }
        .price { font-weight: bold; color: #e74c3c; font-size: 1.2rem; display: block; margin-bottom: 15px; }

        /* Footer */
        footer { background: #2c3e50; color: #fff; text-align: center; padding: 30px 0; margin-top: 50px; }
    </style>
</head>
<body>

    <nav>
        <div class="logo">KubeBytes Travel</div>
        <ul>
            <li><a href="#">Home</a></li>
            <li><a href="#">Packages</a></li>
            <li><a href="#">About</a></li>
            <li><a href="#">Contact</a></li>
        </ul>
    </nav>

    <header class="hero">
        <h1>Explore Your Next Adventure</h1>
        <p>Premium travel experiences designed for DevOps professionals and explorers alike.</p>
        <a href="#packages" class="btn">View Packages</a>
    </header>

    <div class="container" id="packages">
        <div class="section-title">
            <h2>Our Popular Destinations</h2>
        </div>

        <div class="packages-grid">
            <div class="card">
                <img src="https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80" alt="Paris">
                <div class="card-content">
                    <h3>Romantic Paris</h3>
                    <p>Experience the lights of the Eiffel Tower and world-class museums in the heart of France.</p>
                    <span class="price">$1,200</span>
                    <a href="#" class="btn">Book Now</a>
                </div>
            </div>

            <div class="card">
                <img src="https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=600&q=80" alt="Venice">
                <div class="card-content">
                    <h3>Venice Canals</h3>
                    <p>Enjoy a serene gondola ride through the historic and beautiful waterways of Venice, Italy.</p>
                    <span class="price">$1,450</span>
                    <a href="#" class="btn">Book Now</a>
                </div>
            </div>

            <div class="card">
                <img src="https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80" alt="Bali">
                <div class="card-content">
                    <h3>Bali Paradise</h3>
                    <p>Relax in tropical luxury with our all-inclusive beach resort package in stunning Bali.</p>
                    <span class="price">$980</span>
                    <a href="#" class="btn">Book Now</a>
                </div>
            </div>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 KubeBytes DevOps Training Institute. All Rights Reserved.</p>
    </footer>

</body>
</html>
