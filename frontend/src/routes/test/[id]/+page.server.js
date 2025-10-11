export async function load({ params }) {
 const data = {
    id: params.id,
    timeStamp: new Date().toLocaleDateString(),
    message: "You're viewing item: ${params.id}",
    funFact: 'This is data point #${params.id}'
  };
  return { data };
}
