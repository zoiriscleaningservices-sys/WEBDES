// app.js
import { auth, googleProvider } from "./firebase.js";
import { signInWithEmailAndPassword, signInWithPopup, setPersistence, browserLocalPersistence, browserSessionPersistence, onAuthStateChanged, signOut } from "firebase/auth";

const loginForm = document.getElementById('loginForm');
const googleBtn = document.getElementById('googleLogin');
const rememberCheckbox = document.getElementById('remember');
const userDiv = document.getElementById('userDiv');
const loginDiv = document.getElementById('loginDiv');
const userName = document.getElementById('userName');
const logoutBtn = document.getElementById('logout');

loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = loginForm.email.value;
    const password = loginForm.password.value;
    const persistence = rememberCheckbox.checked ? browserLocalPersistence : browserSessionPersistence;

    try {
        await setPersistence(auth, persistence);
        await signInWithEmailAndPassword(auth, email, password);
        loginForm.reset();
    } catch (err) {
        alert(err.message);
    }
});

googleBtn.addEventListener('click', async () => {
    try {
        await setPersistence(auth, rememberCheckbox.checked ? browserLocalPersistence : browserSessionPersistence);
        await signInWithPopup(auth, googleProvider);
    } catch (err) {
        alert(err.message);
    }
});

onAuthStateChanged(auth, user => {
    if (user) {
        loginDiv.style.display = "none";
        userDiv.style.display = "flex";
        userName.textContent = user.displayName || user.email;
    } else {
        loginDiv.style.display = "block";
        userDiv.style.display = "none";
    }
});

logoutBtn.addEventListener('click', () => signOut(auth));
