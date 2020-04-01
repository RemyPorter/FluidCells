//CELL TYPES
final int EMPTY = 0;
final int LEADING = 1;
final int TRAILING = 2;
final int LINGER = 10;
final int REFLECTED = 3;
final int REFLECT_FADE = 4;
final int REFLECT_STOP = 5;
final int REFLECTOR = 6;
final int SOURCE = 7;
final int WAITER = 8;
final int DOUBLE = 9;
final int BLOCKER = 11;

//How many cells in our grid
int PLAYFIELD_SIZE = 200;

//START UTILITY METHODS
//These handle some of the core logic like finding things in our neighborhood
int[] neighborhood = {-1, 0, 1};

boolean inNeighborhood(int x, int y, int[][] playfield, int value) {
  for (int i : neighborhood) {
    for (int j : neighborhood) {
      if (x+i < 0 || x+i >= PLAYFIELD_SIZE || y+j < 0 || y+j >= PLAYFIELD_SIZE) continue;
      if (playfield[x+i][y+j] == value) return true;
    }
  }
  return false;
}

int countInNeighborhood(int x, int y, int[][] playfield, int value) {
  int res = 0;
  for (int i : neighborhood) {
    for (int j : neighborhood) {
      if (x+i < 0 || x+i >= PLAYFIELD_SIZE || y+j < 0 || y+j >= PLAYFIELD_SIZE) continue;
      if (playfield[x+i][y+j] == value) res++;
    }
  }
  return res;
}
//END UTILITY METHODS

/**
These are our rules. This is the key logic of everything which drives this animation.
**/
void evaluateCell(int x, int y, int[][] playfield, int[][] nextField) {
  if (playfield[x][y] == LEADING) {
    if (inNeighborhood(x,y,playfield,BLOCKER)) {
      nextField[x][y] = TRAILING;
    } else if (countInNeighborhood(x,y,playfield,REFLECTOR) > 2) {
      nextField[x][y] = REFLECTED;
    } else if (countInNeighborhood(x, y, playfield, LEADING) > 5) {
      nextField[x][y] = DOUBLE;
    } else {
      nextField[x][y] = TRAILING;
    }
  } else if (playfield[x][y] == TRAILING) {
    nextField[x][y] = LINGER;
  } else if (playfield[x][y] == LINGER) {
    nextField[x][y] = EMPTY;
  } else if (playfield[x][y] == EMPTY && inNeighborhood(x, y, playfield, LEADING)) {
    nextField[x][y] = LEADING;
  } else if (playfield[x][y] == EMPTY && countInNeighborhood(x, y, playfield, REFLECT_FADE) > 1) {
    nextField[x][y] = LEADING;
  } else if (playfield[x][y] == EMPTY && inNeighborhood(x, y, playfield, SOURCE)) {
    nextField[x][y] = LEADING;
  } else if (playfield[x][y] == REFLECTED) {
    nextField[x][y] = REFLECT_FADE;
  } else if (playfield[x][y] == REFLECT_FADE) {
    nextField[x][y] = REFLECT_STOP;
  } else if (playfield[x][y] == REFLECT_STOP) {
    nextField[x][y] = TRAILING;
  } else if (playfield[x][y] == DOUBLE) {
    nextField[x][y] = REFLECTED;
  }else {
    nextField[x][y] = playfield[x][y];
  }
}

/**
Draw a cell. This is where you can change the color palette.
**/
void drawCell(int x, int y, int value) {
  noStroke();
  switch (value) {
    case EMPTY:
    case LINGER:
      fill(0);
      break;
    case LEADING:
      fill(#FF00FF);
      break;
    case TRAILING:
      fill(#880088);
      break;
    case REFLECTOR:
      fill(#FFFF00);
      break;
    case REFLECT_FADE:
      fill(#008888);
      break;
    case REFLECTED:
      fill(#00FF00);
      break;
    case DOUBLE:
      fill(#338833);
      break;
    case BLOCKER:
      fill(#550000);
      break;
  }
  rect(x, y, 1, 1);
}

int[][] playfield = new int[PLAYFIELD_SIZE][PLAYFIELD_SIZE];

void setup() {
  size(640, 640, P3D);
  for (int i = 0; i < PLAYFIELD_SIZE; i++) {
    for (int j = 0; j < PLAYFIELD_SIZE; j++) {
      playfield[i][j] = EMPTY;
    }
  }
  /*******
  This section is where you can draw the initial playfield. Do what you will here.
  Put leadings, reflectors, blockers, etc.
  *******/
  playfield[PLAYFIELD_SIZE/2+1][PLAYFIELD_SIZE/2] = LEADING;
  
  for (int i = 0; i < 100; i++) {
    playfield[PLAYFIELD_SIZE/2+i][20] = REFLECTOR;
    playfield[PLAYFIELD_SIZE/2-i][40] = REFLECTOR;
    playfield[PLAYFIELD_SIZE/2-29][PLAYFIELD_SIZE/2+i] = REFLECTOR;
    playfield[PLAYFIELD_SIZE/2+30][PLAYFIELD_SIZE/2+i] = REFLECTOR;
    //playfield[PLAYFIELD_SIZE/2][PLAYFIELD_SIZE/3+i] = BLOCKER;
  }
  frameRate(30);
}

void step() {
  int[][] next = new int[PLAYFIELD_SIZE][PLAYFIELD_SIZE];
  for (int i = 0; i < PLAYFIELD_SIZE; i++) {
    for (int j = 0; j < PLAYFIELD_SIZE; j++) {
      evaluateCell(i, j, playfield, next);
    }
  }
  playfield = next;
}

void clearField() {
  for (int x = 0; x < PLAYFIELD_SIZE; x++) {
    for (int y = 0; y < PLAYFIELD_SIZE; y++) {
      if (playfield[x][y] != EMPTY && playfield[x][y] != REFLECTOR && playfield[x][y] != BLOCKER) playfield[x][y] = EMPTY;
    }
  }
}

//There are a few utilities which let you draw. This was just for my convenience and shouldn't be taken to be useful
int drawWith = LEADING;
boolean paused = false;
void keyPressed() {
  if (key == 'r') {
    drawWith = REFLECTOR;
  } else if (key == 'l') {
    drawWith = LEADING;
  } else if (key == 'c') {
    clearField();
  } else if (key == ' ') {
    paused = !paused;
  }
}

void mouseClicked() {
  mouseDragged();
}

void mouseDragged() {
  int x = (int)(((float)mouseX) / width * PLAYFIELD_SIZE);
  int y = (int)(((float)mouseY) / height * PLAYFIELD_SIZE);
  playfield[x][y] = drawWith;
}

void draw() {
  if (paused) return;
  step();
  clear();
  scale(((float)width)/PLAYFIELD_SIZE, ((float)height)/PLAYFIELD_SIZE);
  for (int i = 0; i < PLAYFIELD_SIZE; i++) {
    for (int j = 0; j < PLAYFIELD_SIZE; j++) {
      drawCell(i, j, playfield[i][j]);
    }
  }
  //saveFrame("to_chaos/####.tiff"); //for exporting files to make videos with
}
