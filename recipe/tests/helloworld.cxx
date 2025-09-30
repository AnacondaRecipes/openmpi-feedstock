
// Openmpi since version =>5 and higher were removed C++ binding,
// therefore, C++ testing code is using C binding.

#include <mpi.h>
#include <iostream>
#include <vector>

int main(int argc, char *argv[]) {
    MPI_Init(&argc, &argv);

    int size = 0, rank = 0;
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int name_len = 0;
    char name[MPI_MAX_PROCESSOR_NAME];
    MPI_Get_processor_name(name, &name_len);

    std::cout << "Hello, World! "
              << "I am process " << rank
              << " of " << size
              << " on " << name
              << "." << std::endl;

    MPI_Finalize();
    return 0;
}
