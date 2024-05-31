interface Bus {
    void reset();
    char output(Node node);
    char output(int x, int y);
    void update(char bit, Node node);
}
