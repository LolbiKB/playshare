import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
    <Header />
    <Librabry />
    </div>
  );
}

function Header() {
  return (
    <header>
      playshare
    </header>
  );
}

function Librabry() 
{
  return (
    <div class="wrapper">
	<h1>Top 10 albums of 2021</h1>
	<cite>Source: <a href="https://www.theguardian.com/music/2021/nov/30/the-50-best-albums-of-2021">The Guardian</a></cite>
	<ol reversed start="20">
		<li>
			<span>Arooj Aftab</span>
			<span>Vulture Prince</span>
		</li>
		<li>
			<span>Dave</span>
			<span>We’re All Alone in This Together</span>
		</li>
		<li>
			<span>Turnstile</span>
			<span>Glow On</span>
		</li>
		<li>
			<span>Tirzah</span>
			<span>Colourgrade</span>
		</li>
		<li>
			<span>Deafheaven</span>
			<span>Infinite Granite</span>
		</li>
		<li>
			<span>Nick Cave and Warren Ellis</span>
			<span>Carnage</span>
		</li>
		<li>
			<span>Lil Nas X</span>
			<span>Montero</span>
		</li>
		<li>
			<span>Japanese Breakfast</span>
			<span>Jubilee</span>
		</li>
		<li>
			<span>Jazmine Sullivan</span>
			<span>Heaux Tales</span>
		</li>
		<li>
			<span>Sam Fender</span>
			<span>Seventeen Going Under</span>
		</li>
	</ol>
	
	<div class="divider"></div>
	
	<ol reversed>
		<li>
			<span>Mdou Moctar</span>
			<span>Afrique Victime</span>
		</li>
		<li>
			<span>Arlo Parks</span>
			<span>Collapsed in Sunbeams</span>
		</li>
		<li>
			<span>Olivia Rodrigo</span>
			<span>Sour</span>
		</li>
		<li>
			<span>Dry Cleaning</span>
			<span>New Long Leg</span>
		</li>
		<li>
			<span>Sault</span>
			<span>Nine</span>
		</li>
		<li>
			<span>Tyler, the Creator</span>
			<span>Call Me If You Get Lost</span>
		</li>
		<li>
			<span>The Weather Station</span>
			<span>Ignorance</span>
		</li>
		<li>
			<span>Little Simz</span>
			<span>Sometimes I Might Be Introvert</span>
		</li>
		<li>
			<span>Wolf Alice</span>
			<span>Blue Weekend</span>
		</li>
		<li>
			<span>Self Esteem</span>
			<span>Prioritise Pleasure</span>
		</li>
	</ol>
</div>
  );
}

export default App;
