// 制作物データ
const projects = [
  {
    title: "ToDoリストアプリ",
    description: "ローカルストレージに対応した簡単なToDoアプリです。",
    url: "https://your-username.github.io/todo-app/"
  },
  {
    title: "天気予報アプリ",
    description: "OpenWeatherMap APIを使った天気アプリ。",
    url: "https://your-username.github.io/weather-app/"
  }
];

// DOMに表示
const container = document.getElementById("projects");

projects.forEach(project => {
  const col = document.createElement("div");
  col.className = "col-md-6";

  col.innerHTML = `
    <div class="card h-100 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">${project.title}</h5>
        <p class="card-text">${project.description}</p>
        <a href="${project.url}" class="btn btn-primary" target="_blank">見る</a>
      </div>
    </div>
  `;

  container.appendChild(col);
});
