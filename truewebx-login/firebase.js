// firebase.js
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyAHZ5v86FWK9uU-9LfZKaBsMR6QQ92JqQM",
  authDomain: "truewebx-78890.firebaseapp.com",
  projectId: "truewebx-78890",
  storageBucket: "truewebx-78890.appspot.com",
  messagingSenderId: "578628752073",
  appId: "1:578628752073:web:c916cc3f234865a2947318",
  measurementId: "G-0RVDLJX2LD"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();

export { auth, googleProvider };
