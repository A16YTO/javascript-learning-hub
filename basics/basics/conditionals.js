let age = 20;
let isStudent = true;

if (age < 18) {
  console.log("You're a minor.");
} else if (age >= 18 && age < 65) {
  console.log("You're an adult.");
} else {
  console.log("You're a senior.");
}

if (isStudent) {
  console.log("Welcome, student!");
} else {
  console.log("Welcome, guest!");
}

// Switch example
let day = "Monday";

switch (day) {
  case "Monday":
    console.log("Start of the week!");
    break;
  case "Friday":
    console.log("Almost weekend!");
    break;
  case "Sunday":
    console.log("Rest day.");
    break;
  default:
    console.log("Just another day.");
}

