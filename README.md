# Fluid Cells

As an experiment, I wanted to play with the idea of building a very simple "fluid dynamics" simulation built out of a cellular automata. The goal, as with any CA project, is to build something that has (relatively) simple rules, and creates complex behavior.

Specifically, I want to work on wavefronts. So the first set of rules need to be built around tracing the behavior of a wavefront as cellular automata. To do this part, we need 3 states for each cell: `LEADING`, `TRAILING`, and of course, `EMPTY`.

## Basic Rules

Our rules are as follows:

* If a cell is `LEADING`, it becomes `TRAILING`.
* If a cell is `TRAILING`, it becomes `EMPTY`.
* If a cell is `EMPTY` and there are any `LEADING` cells in its neighborhood, it becomes `LEADING`.

The "neighborhood" in this case is a "Von Neumann" neighborhood, which is to say, every adjacent cell, including diagonals. The result is pretty much what we'd like to see:

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/wavefront.gif" alt="Wavefront Animation">

## Wave Interactions

Great. Now, wavefronts should be able to interact with each other. I want to be able to have two wavefronts interfere. Like true wavefronts, if they're aligned one way, they should destructively interfere (cancel out), or constructively interfere (essentially pass through each other, creating a new wavefront).

This requires more states. First, we need a state to note when there has been constructive interference, which I'll call `DOUBLE`. Then we need to prepare for the new wavefront to spawn, so I'm going to add a state I'll call `REFLECTED` (which we'll use for other tasks in a bit). Finally, I want to make sure we dampen the feedback, so that we don't immediately let a third wavefront spawn, so I'll add `REFLECT_FADE`, which is sort of the `TRAILING` for interference, and a third `REFLECT_STOP` to actually prevent reflections from causing feedback.

We'll add some new rules:

* If a cell is `LEADING` and it has more than 5 `LEADING` cells in its neighborhood, it becomes `DOUBLE`.
* If a cell is `DOUBLE` it becomes `REFLECTED`.
* If a cell is `REFLECTED` it becomes `REFLECT_FADE`
* If a cell is `REFLECT_FADE` it becomes `REFLECT_STOP`
* If a cell is `EMPTY` and has more than 2 `REFLECT_FADE` neighbors, it becomes `LEADING`

With those rules, we can spawn two waves with constructive:

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/constructive.gif" alt="Constructive Interference">

And destructive interference:

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/destructive.gif" alt="Destructive Inteference">

NB: this is not a physical simulation of interference, obviously, because it introduces a time lag into two waves interacting. But it allows wavefronts to pass through each other or to block each other. Someone smarter than me can probably prove some interesting computational side effects of that kind of thing- it sounds like you could build gates that way.

## Objects in the space

Next, let's add a `BLOCKER`. We can try a simple rule with blockers:

* If a cell is `LEADING` and it has a `BLOCKER` in its neighborhood, it becomes `TRAILING`

That gives us a simple way to draw lines which will block the progress of the waveform- to an extent.

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/blocker-simple.gif" alt="Simple blocker">

Because of the way leaders work, they're not purely *blocked*, but "diffract" around the edge of the blocker, much like a real wavefront (though not exactly like a real wavefront). This creates another unusual side effect: what happens when the diffraction creates constructive interference?

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/blocker-complex.gif" alt="Complex blocker setup">

Here, we abandon any pretense of behaving like a real world object. The wave becomes self-reinforcing.

If we spawn more wavefronts, we can cancel that (here, when I click on the screen, a new wavefront spawns).

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/blocker-interact.gif" alt="Blocker with interaction">

## Reflections

Now, I added some states with "reflect" in the name, and the reason was that I wanted to have a way to reflect waves- give them something to bounce back off of. So there's a new cell type- `REFLECTOR`.

* If a cell is `LEADING` and has at least 3 `REFLECTOR`s in its neighborhood, it turns into `REFLECTED`.

The rules for wave interactions continue to work here, so you don't need to add any other rules here.

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/reflector.gif" alt="Reflections">

## Results

So, this allows you to build some semi-complex animations just by arranging a few different reflectors and blockers.

<img src="https://raw.githubusercontent.com/RemyPorter/FluidCells/master/complex_setup.gif" alt="A complex setup with interesting effects">

But because it's possible to create feedback loops, you can very quickly drive this into utter chaos, with minor changes:

[Running to chaos](https://vimeo.com/403095050) needs to be a video, since it's long and does NOT compress well. It gets flash-y, so be warned if that's going to cause you problems.

I actually quite like that reality. Fluid dynamics can get into turbulent states that are chaotic, and these simple rules can produce chaotic behavior through feedback, and that makes me excited. I've seen patterns that get into cavitation-like effects, as well as patterns that turn into whirlpools. It's like super agitated water.

There's no point to any of this. It was a fun thing for me to build, and I'l probably continue playing with this toy and tweaking the rules.

This [gist](https://gist.github.com/RemyPorter/d7acce350e3b94ee84c29c9fd9c9dffe) contains the code I used to generate these animations. I've annotated it some, to help make it usable for others, but I haven't made a toy application which lets non-programmers play with this. Maybe someone else will?
