// A simple JavaScript object (JSON-like)
let user = {
  name: "Hugh",
  age: 20,
  isStudent: true,
  hobbies: ["coding", "reading", "gaming"]
};

// Accessing properties
console.log("Name:", user.name);
console.log("First hobby:", user.hobbies[0]);

// Modifying properties
user.age = 21;
user.hobbies.push("music");

// Converting to JSON string
let jsonString = JSON.stringify(user);
console.log("JSON string:", jsonString);

// Parsing JSON string back to object
let parsedUser = JSON.parse(jsonString);
console.log("Parsed user name:", parsedUser.name);

