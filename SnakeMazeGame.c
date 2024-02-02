#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include <termios.h>
#include <unistd.h>

#define BOARD_WIDTH 40
#define BOARD_HEIGHT 25

char board[BOARD_WIDTH][BOARD_HEIGHT];

void initializeBoard()
{
    for (int x = 0; x < BOARD_WIDTH; x++) {
        for (int y = 0; y < BOARD_HEIGHT; y++) {
            if (x == 0 || x == BOARD_WIDTH - 1 || y == 0 || y == BOARD_HEIGHT - 1) {
                board[x][y] = '#';  // set border
            } else {
                board[x][y] = ' ';  // set empty space
            }
        }
    }
}

void clearScreen()
{
    printf("\033[2J");  // escape sequence to clear screen
    printf("\033[%d;%dH", 0, 0);  // move cursor to top-left corner
    fflush(stdout);  // flush output buffer to display changes
}

void drawScreen()
{
   clearScreen();  // clear the screen

    // draw board
    for (int y = 0; y < BOARD_HEIGHT; y++) {
        for (int x = 0; x < BOARD_WIDTH; x++) {
            printf("%c", board[x][y]);
        }
        printf("\n");
    }

    // draw other game elements here (e.g. characters, obstacles, etc.)

    fflush(stdout);  // flush output buffer to display changes
}

// function to get a single character without echo
char getch() {
    char ch;
    struct termios oldt, newt;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return ch;
}


int main()
{
    
    initializeBoard();
    
    int score = 0;
    int x = 10, y = 10; // starting position of the object
    int num_obstacles = 10;
    int obstacles[num_obstacles][2];
    int obstacle_collision = 0;
    srand(time(0)); // seed the random number generator
    int num_chars_eaten = 0;
    int max_chars=5;
    int small_char_x;  // array to store x coordinates of small characters
    int small_char_y;  // array to store y coordinates of small characters
    int min_x = 5;
    int max_x = 25;
    int min_y = 5;
    int max_y = 25;
    printf("Press enter to start:\n");

drawScreen();

 
    for (int i = 0; i < num_obstacles; i++)
    {
        obstacles[i][0] = rand() % 21; // random x coordinate between 0 and 20
        obstacles[i][1] = rand() % 21; // random y coordinate between 0 and 20
    }


    while (1)
    {

        // move the object
        char ch = getch();
        if (ch == 'w') y--; // move up
        if (ch == 's') y++; // move down
        if (ch == 'a') x--; // move left
        if (ch == 'd') x++; // move right

        // check for boundaries
        if (x < 5) x = 5;
        if (x > 25) x = 25;
        if (y < 5) y = 5;
        if (y > 25) y = 25;

       // check for collisions with obstacles
        for (int i = 0; i < num_obstacles; i++)
        {
            if (x == obstacles[i][0] && y == obstacles[i][1])
            {
                printf("Collision with obstacle!\n");
                obstacle_collision = 1;
                break;
            }
        }

        if(obstacle_collision) break;


        // check for collision with small character
        if (x == small_char_x && y == small_char_y)
        {
            printf("Ate the small character!\n");
            num_chars_eaten++;
            score++;
            if (num_chars_eaten == max_chars)
            {
                printf("Congratulations, you have eaten all the characters!\n");
                break;
            }
            small_char_x = rand() % 26; // move the small character to a new random position
            small_char_y = rand() % 26;
        }
        if(obstacle_collision) break;

        //clear the previous object position
        printf("\033[%d;%dH", y-1, x);
        printf("                                            ");
        printf("\033[%d;%dH", y, x-1);
        printf("                                            ");
        printf("\033[%d;%dH", y, x);
        printf("                                            ");
        printf("\033[%d;%dH", y+1, x);
        printf("                                            ");
        printf("\033[%d;%dH", y, x+1);
        printf("                                            ");



        // draw the object
        printf("\033[%d;%dH", y, x); // move cursor to new position
        printf("|x|\n");

        // draw the obstacles
        for (int i = 0; i < num_obstacles; i++)
        {
            printf("\033[%d;%dH", obstacles[i][1], obstacles[i][0]);
            printf("[0]");
        }

     if (small_char_x < min_x) small_char_x = min_x;
    if (small_char_x > max_x) small_char_x = max_x;
    if (small_char_y < min_y) small_char_y = min_y;
    if (small_char_y > max_y) small_char_y = max_y;
       
 // draw the small character
        printf("\033[%d;%dH", small_char_y, small_char_x);
        printf("<^>");

printf("Score: %d\n", score);
        // delay (part of terminos.h)
        usleep(100000);
    }


    return 0;
}
