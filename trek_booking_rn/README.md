# Nepal Trek Explorer - BCA 6th Semester Project

## 🎓 Project Overview

**Nepal Trek Explorer** is a modern travel & trekking booking application built with React Native (Expo), designed specifically for Tribhuvan University BCA 6th Semester academic requirements. This project demonstrates the practical implementation of various **Data Structures and Algorithms** in a real-world mobile application.

### Key Features
- 🏔 **Beautiful Trek Listings** with search, filter, and sort
- 🤖 **AI Trip Planner** using rule-based recommendation algorithm
- 📊 **Algorithm Visualization** - step-by-step execution display
- 🎯 **Educational Mode** - learn CS concepts interactively
- 📱 **Modern UI/UX** - inspired by premium travel apps
- 🧠 **7 Algorithms Implemented** with visual demonstrations

---

## 🧮 Algorithms Implemented

This project implements the following computer science algorithms:

| Algorithm | Use Case | Time Complexity | Implementation |
|-----------|----------|----------------|----------------|
| **Binary Search** | Fast trip search by ID | O(log n) | [`BinarySearch.js`](src/algorithms/BinarySearch.js) |
| **Quick Sort** | Sort trips by price/rating/duration | O(n log n) avg | [`QuickSort.js`](src/algorithms/QuickSort.js) |
| **BFS (Breadth-First Search)** | Find routes between locations | O(V + E) | [`GraphAlgorithm.js`](src/algorithms/GraphAlgorithm.js) |
| **DFS (Depth-First Search)** | Explore trek routes | O(V + E) | [`GraphAlgorithm.js`](src/algorithms/GraphAlgorithm.js) |
| **Dijkstra's Algorithm** | Shortest path calculation | O((V + E) log V) | [`GraphAlgorithm.js`](src/algorithms/GraphAlgorithm.js) |
| **Greedy Algorithm** | Budget optimization | O(n log n) | [`GreedyAlgorithm.js`](src/algorithms/GreedyAlgorithm.js) |
| **Dynamic Programming** | Trip planning (0/1 Knapsack) | O(n * W) | [`DynamicProgramming.js`](src/algorithms/DynamicProgramming.js) |
| **Recommendation Engine** | AI-based trip suggestions | O(n) | [`RecommendationAlgorithm.js`](src/algorithms/RecommendationAlgorithm.js) |

---

## 🛠 Tech Stack

### Frontend
- **Framework**: React Native with Expo SDK 51
- **Styling**: NativeWind (Tailwind CSS for React Native)
- **Navigation**: React Navigation (Stack + Bottom Tabs)
- **State Management**: Zustand
- **Icons**: MaterialIcons (@expo/vector-icons)
- **Gradients**: expo-linear-gradient

### Architecture
- Component-based architecture
- Custom hooks for state management
- Algorithm modules separated for clarity
- Mock API layer (API-ready for backend integration)

---

## 📁 Project Structure

```
trek_booking_rn/
├── App.js                          # Main app entry with navigation
├── package.json                    # Dependencies
├── app.json                        # Expo configuration
├── babel.config.js                 # Babel configuration
├── tailwind.config.js              # Tailwind CSS config
│
├── src/
│   ├── algorithms/                 # All algorithm implementations
│   │   ├── BinarySearch.js         # Binary search with visualization
│   │   ├── QuickSort.js            # Quick sort implementation
│   │   ├── GraphAlgorithm.js       # BFS, DFS, Dijkstra
│   │   ├── GreedyAlgorithm.js      # Greedy optimization
│   │   ├── DynamicProgramming.js   # DP for trip planning
│   │   └── RecommendationAlgorithm.js  # AI recommendation
│   │
│   ├── components/                 # Reusable UI components
│   │   ├── TripCard.js             # Trip display card
│   │   ├── FilterBar.js            # Search & filter UI
│   │   └── AlgorithmVisualizer.js  # Algorithm step visualization
│   │
│   ├── screens/                    # All app screens
│   │   ├── HomeScreen.js           # Landing page
│   │   ├── TripListScreen.js       # Browse all treks
│   │   ├── TripDetailsScreen.js    # Trip details view
│   │   ├── AIPlannerScreen.js      # AI trip planner
│   │   └── EducationalPanelScreen.js # Algorithm learning
│   │
│   ├── store/                      # State management
│   │   └── useStore.js             # Zustand store
│   │
│   └── data/                       # Mock data
│       └── mockData.js             # 8 sample treks with full details
│
└── README.md                       # This file
```

---

## 🚀 Installation & Setup

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn
- Expo CLI
- Expo Go app (for testing on phone)

### Step 1: Clone the Repository
```bash
cd c:\Users\sazna\6th_sem
cd trek_booking_rn
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Start the Development Server
```bash
npx expo start
```

### Step 4: Run on Device/Emulator
- Scan QR code with **Expo Go** (Android/iOS)
- Press `a` for Android emulator
- Press `i` for iOS simulator (Mac only)
- Press `w` for web browser

---

## 📱 Core Screens

### 1. Home Screen
- Hero banner with featured treks
- Category explorer (Trekking, Cultural, Peak Climbing)
- Quick statistics
- Trending treks
- AI Trip Planner CTA
- Educational mode toggle

### 2. Explore Treks Screen
- Search bar with real-time filtering
- Advanced filters (region, difficulty, price, duration, season)
- Sort options (price, rating, popularity, duration)
- Grid/List view of trips
- Uses **Quick Sort** for sorting

### 3. Trip Details Screen
- Image carousel
- Tabs: Overview, Itinerary, Details, Reviews
- Booking CTA
- Save to favorites
- Season information
- Inclusions/Exclusions

### 4. AI Trip Planner Screen
- Input: Budget, Days, Difficulty, Season
- Algorithm selector (Educational mode):
  - Rule-based Recommendation
  - Greedy Algorithm
  - Dynamic Programming
- Top 5 recommendations with scores
- Reason explanation for each recommendation
- Algorithm visualization

### 5. Educational Panel Screen
- 7 Algorithm cards with descriptions
- Click to run and visualize
- Step-by-step execution display
- Complexity analysis
- Learning resources
- Academic project notes

---

## 🎨 UI/UX Features

### Design Philosophy
- **Nature-inspired color scheme** (Green theme)
- **Large visuals** with high-quality images
- **Card-based layouts** for modern feel
- **Smooth animations** using React Native Animated API
- **Intuitive navigation** with bottom tabs
- **Accessible** with proper color contrast

### Color Palette
```javascript
Primary Green: #2E7D32
Light Green: #4CAF50
Accent Green: #66BB6A
Orange Accent: #FF9800
Background: #f9f9f9
Text: #1a1a1a
```

---

## 🧪 Educational Features

### Algorithm Visualizer
The app includes a comprehensive algorithm visualizer that shows:
- **Step-by-step execution** with play/pause controls
- **Progress bar** showing current step
- **Metrics display** (comparisons, swaps, nodes visited)
- **Time complexity** information
- **Color-coded steps** (start, compare, swap, found, etc.)
- **Educational descriptions** for each algorithm

### How to Use Educational Mode
1. Tap **school icon** in home screen header
2. Navigate to **Learn** tab
3. Select any algorithm
4. Watch step-by-step visualization
5. Use play/pause controls
6. Read learning resources

---

## 📊 Algorithm Use Cases in App

### 1. Binary Search
- **Where**: Trip search by ID
- **Demo**: Educational panel → Binary Search
- **Benefit**: O(log n) vs O(n) comparison shown

### 2. Quick Sort
- **Where**: Trip list sorting (price, rating, duration)
- **Demo**: Explore screen → Sort button
- **Benefit**: Fast sorting with visualization

### 3. Graph Algorithms (BFS/DFS/Dijkstra)
- **Where**: Route finding between trek locations
- **Demo**: Educational panel → Graph algorithms
- **Benefit**: Find paths, shortest routes

### 4. Greedy Algorithm
- **Where**: Budget-based trip selection
- **Demo**: AI Planner → Select Greedy
- **Benefit**: Maximize trips within budget

### 5. Dynamic Programming
- **Where**: Optimal trip planning
- **Demo**: AI Planner → Select DP
- **Benefit**: Best combination of trips

### 6. Recommendation Algorithm
- **Where**: AI trip suggestions
- **Demo**: AI Planner → Get Recommendations
- **Benefit**: Personalized trip matching

---

## 🎯 For TU BCA Project Submission

### Report Structure Suggestion

#### Chapter 1: Introduction
- Problem statement: Manual trip planning is time-consuming
- Objectives: Build algorithmic booking system
- Scope: Mobile app with 7 algorithms

#### Chapter 2: Literature Review
- Existing travel apps
- Algorithm applications in booking systems
- Gap analysis

#### Chapter 3: System Analysis & Design
- Use case diagrams
- ER diagrams (for future database)
- Flowcharts of algorithms
- Screen mockups

#### Chapter 4: Implementation
- Tech stack justification
- Algorithm implementations (include code snippets)
- Screenshots of each screen

#### Chapter 5: Testing
- Algorithm testing (show step outputs)
- UI/UX testing
- Performance comparison (Binary Search vs Linear)

#### Chapter 6: Conclusion & Future Work
- Achievements
- Limitations
- Future enhancements (backend, payment, etc.)

### Viva Questions You Should Prepare
1. Why did you choose React Native over Flutter?
2. Explain how Binary Search works in your app
3. What's the time complexity of Quick Sort? Why?
4. How does Dijkstra's algorithm find shortest path?
5. Difference between Greedy and Dynamic Programming?
6. How does your recommendation algorithm work?
7. What state management library did you use? Why Zustand?
8. How would you add a backend to this app?
9. Explain the algorithm visualizer implementation
10. What design patterns did you use?

### Key Features to Highlight in Viva
✅ **7 algorithms implemented** with full visualization  
✅ **Educational mode** for learning  
✅ **Modern UI/UX** comparable to commercial apps  
✅ **Reusable components** for scalability  
✅ **Clean code** with proper documentation  
✅ **Real-world application** of DSA concepts  

---

## 🔧 Customization

### Adding New Trips
Edit [`src/data/mockData.js`](src/data/mockData.js):
```javascript
export const mockTrips = [
  {
    id: '9',
    title: 'Your Trek Name',
    region: 'Region',
    duration: 10,
    difficulty: 'Moderate',
    price: 999,
    // ... more fields
  },
  // ... existing trips
];
```

### Changing Theme Colors
Edit [`tailwind.config.js`](tailwind.config.js):
```javascript
colors: {
  primary: {
    500: '#4CAF50', // Change this
    // ... other shades
  }
}
```

### Adding New Algorithms
1. Create file in `src/algorithms/`
2. Implement with step tracking
3. Add to Educational Panel screen
4. Update README

---

## 📸 Screenshots

*Add screenshots of your running app here*

1. Home Screen
2. Trip List with Filters
3. Trip Details
4. AI Planner
5. Algorithm Visualization
6. Educational Panel

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: Metro bundler error
```bash
# Solution: Clear cache
npx expo start --clear
```

**Issue**: Module not found
```bash
# Solution: Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

**Issue**: Tailwind styles not working
```bash
# Solution: Check babel.config.js includes nativewind/babel
```

---

## 🚀 Future Enhancements

- [ ] **Backend Integration** (Node.js + MongoDB)
- [ ] **User Authentication** (Firebase or JWT)
- [ ] **Payment Gateway** (Stripe/Khalti)
- [ ] **Real-time Booking** (WebSocket)
- [ ] **Push Notifications** (Expo Push)
- [ ] **Offline Mode** (AsyncStorage)
- [ ] **More Algorithms** (A*, Floyd-Warshall)
- [ ] **3D Trek Preview** (Three.js)
- [ ] **AR Features** (Expo Camera)
- [ ] **Social Sharing**
- [ ] **Trip Gallery** (user uploads)

---

## 👨‍💻 Author

**BCA 6th Semester Project**  
Tribhuvan University  
Academic Year: 2026

---

## 📝 License

This project is created for educational purposes as part of BCA curriculum.

---

## 🙏 Acknowledgments

- Tribhuvan University faculty
- Expo team for amazing framework
- React Native community
- Nepal tourism images from Unsplash

---

## 📞 Support

For queries related to this project:
- Email: [Your email]
- GitHub: [Your GitHub]

---

## ⭐ Star this Repository

If this project helps you with your BCA project, please give it a star!

---

**Built with ❤️ for Nepal's trekking enthusiasts and CS students**
